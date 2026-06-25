//
//  CloudKitSyncManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/24.
//

import CoreData
import CloudKit
import Combine
import Network

/// CoreData CloudKit 同步状态工具类
class CloudKitSyncManager {
    
    // MARK: - 单例
    static let shared = CloudKitSyncManager()
    
    // MARK: - 发布属性
    @Published private(set) var isSyncEnabled: Bool = false
    @Published private(set) var lastSyncTime: Date?
    @Published private(set) var isSyncing: Bool = false
    @Published private(set) var syncError: Error?
    
    // iCloud 账户状态
    @Published private(set) var iCloudAccountStatus: CKAccountStatus = .couldNotDetermine
    @Published private(set) var isiCloudAvailable: Bool = false
    @Published private(set) var isNetworkAvailable: Bool = true
    @Published private(set) var cloudKitStatus: CloudKitStatus = .unknown
    
    // MARK: - CloudKit 状态枚举
    enum CloudKitStatus: CustomStringConvertible {
        case unknown
        case available
        case noAccount
        case restricted
        case temporarilyUnavailable
        case noNetwork
        case disabled
        case notDetermined
        
        var description: String {
            switch self {
            case .unknown: return resGetString("Unknown")
            case .available: return resGetString("Available")
            case .noAccount: return resGetString("No Account")
            case .restricted: return resGetString("Restricted")
            case .temporarilyUnavailable: return resGetString("Temporarily Unavailable")
            case .noNetwork: return resGetString("No Network")
            case .disabled: return resGetString("Disabled")
            case .notDetermined: return resGetString("Cannot Determine")
            }
        }
        
        var isAvailable: Bool {
            return self == .available
        }
        
        var color: UIColor {
            switch self {
            case .available: return .green
            case .noAccount: return .orange
            case .restricted: return .red
            case .temporarilyUnavailable: return .yellow
            case .noNetwork: return .orange
            case .disabled: return .red
            case .unknown, .notDetermined: return .gray
            }
        }
    }
    
    // MARK: - 私有属性
    private var container: NSPersistentCloudKitContainer?
    private var cancellables: Set<AnyCancellable>?
    private let userDefaultsKey = "CloudKitLastSyncTime"
    private let networkMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.cloudkit.network.monitor")
    
    private init() {
        loadLastSyncTime()
        startNetworkMonitoring()
    }
    
    // MARK: - 配置容器
    func configure(with container: NSPersistentCloudKitContainer) {
        self.container = container
        checkCloudKitStatus()
        checkiCloudAccountStatus()
    }
    
    // MARK: - 开始 / 结束监听
    func startObserving() {
        guard cancellables == nil else { return }
        cancellables = Set<AnyCancellable>()
        
        NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)
            .sink { [weak self] notification in
                self?.handleRemoteChange(notification)
            }
            .store(in: &cancellables!)

        NotificationCenter.default.publisher(for: .CKAccountChanged)
            .sink { [weak self] _ in
                debugPrint("🔄 iCloud 账户发生变化")
                self?.checkiCloudAccountStatus()
            }
            .store(in: &cancellables!)

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                debugPrint("📱 应用回到前台，重新检查状态")
                self?.checkiCloudAccountStatus()
            }
            .store(in: &cancellables!)
    }

    func stopObserving() {
        cancellables = nil
    }
    
    // MARK: - 检查 iCloud 账户状态
    func checkiCloudAccountStatus(completion: ((CloudKitStatus) -> Void)? = nil) {
        CKContainer.default().accountStatus { [weak self] (status, error) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.iCloudAccountStatus = status
                
                if let error = error {
                    debugPrint("❌ 检查 iCloud 账户状态失败: \(error.localizedDescription)")
                    self.cloudKitStatus = .notDetermined
                    self.syncError = error
                    completion?(self.cloudKitStatus)
                    return
                }
                
                self.cloudKitStatus = self.determineCloudKitStatus(accountStatus: status)
                self.isiCloudAvailable = (self.cloudKitStatus == .available)
                
                debugPrint("🔍 iCloud 账户状态: \(status.description)")
                debugPrint("📊 CloudKit 综合状态: \(self.cloudKitStatus.description)")
                
                completion?(self.cloudKitStatus)
            }
        }
    }
    
    // MARK: - 判断 CloudKit 综合状态
    private func determineCloudKitStatus(accountStatus: CKAccountStatus) -> CloudKitStatus {
        if !isNetworkAvailable {
            return .noNetwork
        }
        
        switch accountStatus {
        case .available:
            return isCloudKitConfigured() ? .available : .disabled
        case .noAccount:
            return .noAccount
        case .restricted:
            return .restricted
        case .couldNotDetermine:
            return .notDetermined
        case .temporarilyUnavailable:
            return .temporarilyUnavailable
        @unknown default:
            return .unknown
        }
    }
    
    // MARK: - 检查 CloudKit 是否在 Container 中配置
    private func isCloudKitConfigured() -> Bool {
        guard let container = container else { return false }
        
        return container.persistentStoreDescriptions.contains { description in
            description.options[NSPersistentHistoryTrackingKey] as? Bool == true &&
            description.options[NSPersistentStoreRemoteChangeNotificationPostOptionKey] != nil
        }
    }
    
    // MARK: - 检查 CloudKit 配置状态
    private func checkCloudKitStatus() {
        isSyncEnabled = isCloudKitConfigured()
        debugPrint(isSyncEnabled ? "✅ CloudKit 同步配置已启用" : "❌ CloudKit 同步配置未启用")
    }
    
    // MARK: - 网络监控
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = (path.status == .satisfied)
                
                if path.status == .satisfied {
                    debugPrint("🌐 网络已连接")
                    self?.checkiCloudAccountStatus()
                } else {
                    debugPrint("❌ 网络断开")
                    self?.cloudKitStatus = .noNetwork
                    self?.isiCloudAvailable = false
                }
            }
        }
        networkMonitor.start(queue: monitorQueue)
    }
    
    // MARK: - 处理远程变更
    private func handleRemoteChange(_ notification: Notification) {
        guard let storeUUID = notification.userInfo?[NSStoreUUIDKey] as? String,
              let container = container,
              let store = container.persistentStoreCoordinator.persistentStores.first(where: { $0.identifier == storeUUID }),
              store.type == NSPersistentStore.StoreType.sqlite.rawValue else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.updateSyncTime()
            self?.isSyncing = false
            debugPrint("🔄 CloudKit 数据已同步: \(Date())")
        }
    }
    
    // MARK: - 更新同步时间
    private func updateSyncTime() {
        let now = Date()
        lastSyncTime = now
        UserDefaults.standard.set(now, forKey: userDefaultsKey)
    }
    
    // MARK: - 加载上次同步时间
    private func loadLastSyncTime() {
        lastSyncTime = UserDefaults.standard.object(forKey: userDefaultsKey) as? Date
    }
    
    // MARK: - 公开方法
    
    var isiCloudEnabled: Bool {
        return cloudKitStatus.isAvailable
    }
    
    var lastSyncTimeFormatted: String {
        guard let time = lastSyncTime else { return "从未同步" }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: time, relativeTo: Date())
    }
    
    func triggerSync() {
        guard cloudKitStatus == .available else {
            let message = "iCloud 不可用: \(cloudKitStatus.description)"
            debugPrint("⚠️ \(message)")
            syncError = NSError(domain: "CloudKitSyncManager",
                              code: -1,
                              userInfo: [NSLocalizedDescriptionKey: message])
            return
        }
        
        guard let container = container else {
            debugPrint("⚠️ 未配置 NSPersistentCloudKitContainer")
            return
        }
        
        isSyncing = true
        
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
                debugPrint("🔄 手动触发同步成功")
            } catch {
                syncError = error
                debugPrint("❌ 同步失败: \(error.localizedDescription)")
            }
        } else {
            context.refreshAllObjects()
            debugPrint("📱 没有需要同步的更改")
        }
        
        isSyncing = false
    }
    
    func openiCloudSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    deinit {
        networkMonitor.cancel()
    }
}

// MARK: - CKAccountStatus 扩展
extension CKAccountStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .available: return resGetString("Available")
        case .noAccount: return resGetString("Not Logged In")
        case .restricted: return resGetString("Restricted")
        case .couldNotDetermine: return resGetString("Cannot Determine")
        case .temporarilyUnavailable: return resGetString("Temporarily Unavailable")
        @unknown default: return resGetString("Unknown")
        }
    }
}

// MARK: - 简化的 ViewModel
class iCloudStatusViewModel: ObservableObject {
    @Published var cloudKitStatus: CloudKitSyncManager.CloudKitStatus
    @Published var isNetworkAvailable: Bool
    @Published var isSyncing: Bool
    @Published var lastSyncTime: Date?
    
    private let syncManager = CloudKitSyncManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    var onStatusChanged: ((CloudKitSyncManager.CloudKitStatus) -> Void)?
    
    init() {
        self.cloudKitStatus = syncManager.cloudKitStatus
        self.isNetworkAvailable = syncManager.isNetworkAvailable
        self.isSyncing = syncManager.isSyncing
        self.lastSyncTime = syncManager.lastSyncTime
        self.setupBindings()
    }
    
    private func setupBindings() {
        syncManager.$cloudKitStatus
            .sink { [weak self] status in
                self?.cloudKitStatus = status
                self?.onStatusChanged?(status)
            }
            .store(in: &cancellables)
        
        syncManager.$isNetworkAvailable
            .assign(to: \.isNetworkAvailable, on: self)
            .store(in: &cancellables)
        
        syncManager.$isSyncing
            .assign(to: \.isSyncing, on: self)
            .store(in: &cancellables)
        
        syncManager.$lastSyncTime
            .sink { [weak self] time in
                self?.lastSyncTime = time
            }
            .store(in: &cancellables)
    }
    
    func startObserving() {
        CloudKitSyncManager.shared.startObserving()
    }
    
    func stopObserving() {
        CloudKitSyncManager.shared.stopObserving()
    }
    
    func refreshStatus() {
        syncManager.checkiCloudAccountStatus()
    }
    
    func manualSync() {
        syncManager.triggerSync()
    }
    
    func openSettings() {
        syncManager.openiCloudSettings()
    }
}
