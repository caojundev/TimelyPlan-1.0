//
//  FocusTimer.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/22.
//

import Foundation

struct FocusTimerKey {
    static var identifier: String = "identifier"
    static var order: String = "order"
    static var name: String = "name"
    static var isArchived: String = "isArchived"
}

class FocusTimer: NSObject, Sortable {

    /// 排序因子
    var order: Int64
    
    /// 任务唯一标识
    var identifier: String

    /// 名称
    var name: String?
    
    /// 颜色
    var color: UIColor
    
    /// 备注
    var note: String?
    
    /// 修改日期
    let modificationDate: Date?
    
    /// 是否已归档
    let isArchived: Bool
    
    /// 计时器配置
    private(set) lazy var config: FocusTimerConfig = {
        if let json = configJSON {
            return FocusTimerConfig.model(with: json) ?? .defaultConfig
        }
        
        return .defaultConfig
    }()
    
    /// 计时器配置 JSON 字符串
    private var configJSON: String?
    
    init(content: CDFocusTimer) {
        self.identifier = content.identifier ?? UUID().uuidString
        self.order = content.order
        self.name = content.name
        self.color = content.color ?? kFocusTimerDefaultColor
        self.configJSON = content.configJSON
        self.isArchived = content.isArchived
        self.modificationDate = content.modificationDate
        super.init()
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(name)
        hasher.combine(color)
        hasher.combine(configJSON)
        hasher.combine(isArchived)
        hasher.combine(modificationDate)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? FocusTimer else { return false }
        if self === other { return true }
        return identifier == other.identifier &&
                name == other.name &&
                color == other.color &&
                configJSON == other.configJSON &&
                isArchived == other.isArchived &&
                modificationDate == other.modificationDate
                    
    }
    
    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
}

extension FocusTimer: FocusTimerRepresentable {
    
    /// 获取计时器特征
    var feature: TimerFeature? {
        return TimerFeature(identifier: identifier)
    }
    
    var timerColor: UIColor {
        return self.color
    }
    
    var timerType: FocusTimerType {
        return self.config.timerType ?? .defaultType
    }
    
    var timerDescription: String? {
        return self.config.summary
    }
    
    var timerConfig: FocusTimerConfig? {
        return self.config
    }
    
    /// 计时器信息
    var timerInfo: TextRepresentable? {
        let timerName = self.name ?? resGetString("Untitled")
        let attributedInfo: ASAttributedString = "\("●", .foreground(self.color)) \(timerName)"
        return attributedInfo
    }
}

// MARK: - 编辑计时器
extension FocusTimer {
    
    /// 编辑计时器
    var editingTimer: FocusEditingTimer {
        var timer = FocusEditingTimer()
        timer.name = name
        timer.color = color
        timer.config = config.copy() as? FocusTimerConfig
        return timer
    }

    /// 判断编辑任务内容是否与当前任务相同
    func isSameTimer(as editingTimer: FocusEditingTimer) -> Bool {
        return editingTimer.name == name &&
                editingTimer.color == color &&
                editingTimer.config == config &&
                editingTimer.note == note
    }
}

extension Array where Element == FocusTimer {
    
    /// 所有标识
    var identifiers: [String] {
        return self.map { $0.identifier }
    }
}
