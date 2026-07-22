//
//  FocusTimer.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/22.
//

import Foundation

struct FocusTimerKey {
    static let identifier = "identifier"
    static let order = "order"
    static let name = "name"
    static let isArchived = "isArchived"
    static let isAddedToMyDay = "isAddedToMyDay"
    static let startDate = "startDate"
    static let endDate = "endDate"
}

class FocusTimer: NSObject, SortableIdentifiable {

    /// 任务唯一标识
    var identifier: String

    /// 名称
    var name: String?
    
    /// 颜色
    var color: UIColor
    
    /// 备注
    var note: String?
    
    /// 是否添加到我的一天
    let isAddedToMyDay: Bool
    
    /// 开始日期
    let startDate: Date?
    
    /// 结束日期
    let endDate: Date?
    
    /// 开始时间
    let startTime: Int64
    
    /// 是否已归档
    let isArchived: Bool
    
    /// 修改日期
    let modificationDate: Date?
    
    /// 计时器配置
    private(set) lazy var config: FocusTimerConfig = {
        if let json = configJSON {
            return FocusTimerConfig.model(with: json) ?? .defaultConfig
        }
        
        return .defaultConfig
    }()
    
    /// 计时器配置 JSON 字符串
    private var configJSON: String?
    
    /// 时间计划
    private(set) lazy var timePlan: HabitTimePlan = {
        if let json = timePlanRuleJSON {
            let regularRule = HabitTimePlanRegularRule.model(with: json)
            return HabitTimePlan(regularRule: regularRule)
        }
        
        return HabitTimePlan()
    }()
    
    /// 时间计划规则 JSON 字符串
    private var timePlanRuleJSON: String?
    
    // MARK: - SortableIdentifiable
    /// 排序因子
    var order: Int64
    
    var identifiableKey: String {
        return identifier
    }
    
    // MARK: - Getters
    
    var displayName: String {
        return name ?? resGetString("Untitled Timer")
    }
    
    /// 转换为 DateInterval
    var interval: DateInterval {
        let start = startDate ?? .distantPast
        let end = endDate ?? .distantFuture
        return DateInterval(start: start, end: end)
    }
    
    
    init(content: CDFocusTimer) {
        self.identifier = content.identifier ?? UUID().uuidString
        self.order = content.order
        self.name = content.name
        self.color = content.color ?? FocusConstant.timerDefaultColor
        self.configJSON = content.configJSON
        self.isArchived = content.isArchived
        self.modificationDate = content.modificationDate
        self.timePlanRuleJSON = content.timePlanRuleJSON
        self.isAddedToMyDay = content.isAddedToMyDay
        self.startDate = content.startDate
        self.endDate = content.endDate
        self.startTime = content.startTime
        super.init()
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? FocusTimer else { return false }
        if self === other { return true }
        return editingTimer == other.editingTimer
    }
    
    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let other = object as? FocusTimer {
            return self.identifier == other.identifier
        }
        
        return false
    }
    
}

extension FocusTimer: FocusTimerRepresentable {
    
    /// 获取计时器特征
    var feature: TimerFeature? {
        return TimerFeature(identifier: self.identifier,
                            snapshotName: self.name,
                            snapshotColorHex: self.color.hexString)
    }
    
    var timerColor: UIColor {
        return self.color
    }
    
    var timerType: FocusTimerType {
        return self.config.timerType ?? .defaultType
    }
    
    var timerDescription: String? {
        return config.summary
    }
    
    var timerConfig: FocusTimerConfig? {
        return config
    }
    
    /// 计时器信息
    var timerInfo: TextRepresentable? {
        let timerName = self.name ?? resGetString("Untitled")
        let attributedInfo: ASAttributedString = "\("●", .foreground(self.color)) \(timerName)"
        return attributedInfo
    }
    
    /// 我的一天图标信息
    func myDayIndicator(color: UIColor? = nil) -> ASAttributedString? {
        guard let image = resGetImage("myDay_fill_16") else {
            return nil
        }
        
        return .string(image: image, imageSize: .size(4), imageColor: color)
    }
}

// MARK: - 编辑计时器
extension FocusTimer {
    
    /// 编辑计时器
    var editingTimer: FocusEditingTimer {
        var timer = FocusEditingTimer()
        timer.name = name
        timer.color = color
        timer.isAddedToMyDay = isAddedToMyDay
        timer.startDate = startDate ?? Date().startOfDay()
        timer.endDate = endDate
        timer.startTime = startTime
        timer.config = config.copy() as? FocusTimerConfig
        timer.timePlan = timePlan.copy() as? HabitTimePlan
        return timer
    }

    /// 判断编辑任务内容是否与当前任务相同
    func isSameTimer(as editingTimer: FocusEditingTimer) -> Bool {
        let current = self.editingTimer
        return current == editingTimer && startDate == editingTimer.startDate
    }
}

extension Array where Element == FocusTimer {
    
    /// 所有标识
    var identifiers: [String] {
        return self.map { $0.identifier }
    }
}
