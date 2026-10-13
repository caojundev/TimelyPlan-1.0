//
//  GoalPlan.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation
import UIKit

struct GoalPlanKey {
    static let identifier = "identifier"
    static let order = "order"
    static let name = "name"
    static let isArchived = "isArchived"
    static let startDate = "startDate"
    static let endDate = "endDate"
    static let note = "note"
    static let progress = "progress"
}

class GoalPlan: NSObject, TPHexColorConvertible, SortableIdentifiable {
    
    /// 目标唯一标识
    var identifier: String
    
    /// 排序因子
    var order: Int64
    
    /// 目标名称
    var name: String?
    
    /// 目标颜色
    var colorHex: String?
    
    /// 开始日期
    var startDate: Date?
    
    /// 结束日期
    var endDate: Date?
    
    /// 备注
    var note: String?
    
    /// 进度（0.0 ~ 1.0）
    var progress: Double
    
    /// 是否已归档
    var isArchived: Bool
    
    /// 修改日期
    let modificationDate: Date?
    
    init(identifier: String = UUID().uuidString,
         order: Int64 = 0,
         name: String? = nil,
         colorHex: String?,
         startDate: Date? = nil,
         endDate: Date? = nil,
         note: String? = nil,
         progress: Double = 0.0,
         isArchived: Bool = false,
         modificationDate: Date? = nil) {
        self.identifier = identifier
        self.order = order
        self.name = name
        self.colorHex = colorHex
        self.startDate = startDate
        self.endDate = endDate
        self.note = note
        self.progress = min(max(progress, 0.0), 1.0)
        self.isArchived = isArchived
        self.modificationDate = modificationDate
        super.init()
    }
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return identifier
    }
    
    // MARK: - Getters
    var displayName: String {
        return name ?? resGetString("Untitled Goal")
    }
    
    /// 目标日期区间
    var interval: DateInterval {
        let start = startDate ?? .distantPast
        let end = endDate ?? .distantFuture
        return DateInterval(start: start, end: end)
    }
    
    /// 计划状态（只读，依据进度与起止日期实时判定）
    var status: GoalPlanStatus {
        return GoalPlanStatus(progress: progress,
                              startDate: startDate,
                              endDate: endDate)
    }
    
    var feature: GoalPlanFeature {
         return GoalPlanFeature(identifier: identifiableKey,
                                name: name,
                                colorHex: colorHex)
     }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(progress)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? GoalPlan else { return false }
        if self === other { return true }
        return editingPlan == other.editingPlan
            && progress == other.progress
    }
    
    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let other = object as? GoalPlan {
            return self.identifier == other.identifier
                && self.progress == other.progress
        }
        
        return false
    }
    
    static var inboxPlan: GoalPlan {
        return GoalPlan(identifier: GoalPlanFeature.inboxIdentifier,
                        name: resGetString("Inbox"),
                        colorHex: GoalPlanFeature.inboxFeature.colorHex)
    }
}

struct GoalEditingPlan: Equatable {
    
    var name: String?
    
    var color: UIColor = GoalConfig.goalPlanDefaultColor

    var startDate: Date?
    
    var endDate: Date?
    
    var note: String?
    
    init() {
        let current = Date()
        let startDate = current.startOfDay()
        self.startDate = startDate
        
        let endDate = current.dateByAddingMonths(1) ?? startDate
        self.endDate = endDate.endOfDay()
    }
    
    init(startDate: Date?, endDate: Date?) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    static func == (lhs: GoalEditingPlan, rhs: GoalEditingPlan) -> Bool {
        return lhs.name == rhs.name
            && lhs.color == rhs.color
            && lhs.startDate == rhs.startDate
            && lhs.endDate == rhs.endDate
            && lhs.note == rhs.note
    }
    
    var dateRange: DateRange {
        get {
            return DateRange(startDate: startDate, endDate: endDate)
        }
        
        set {
            self.startDate = newValue.startDate
            self.endDate = newValue.endDate
        }
    }
}

// MARK: - 编辑目标
extension GoalPlan {
    
    /// 编辑目标计划
    var editingPlan: GoalEditingPlan {
        var plan = GoalEditingPlan(startDate: startDate, endDate: endDate)
        plan.name = name
        plan.color = color ?? GoalConfig.goalPlanDefaultColor
        plan.note = note
        return plan
    }
    
    /// 判断编辑内容是否与当前目标相同
    func isSamePlan(as editingPlan: GoalEditingPlan) -> Bool {
        let current = self.editingPlan
        return current == editingPlan
    }
}

// MARK: - 进度总结状态
extension GoalPlan {
    
    /// 进度总结状态（只读，依据计划进度与起止日期实时判定）。
    ///
    /// 进度差 = 计划进度 − 时间进度，因此除逾期外还能区分领先 / 同步 / 落后 / 严重落后；
    /// 已完成与逾期直接复用 `status`，保证两处判定口径一致。
    var summaryStatus: GoalSummaryStatus {
        return GoalSummaryStatus(gap: progress - timeProgress,
                                 isOverdue: status == .overdue,
                                 isCompleted: status == .completed)
    }
    
    /// 时间进度：已流逝时间占整体计划时长的比例，算法与 `GoalSummaryCalculator` 保持一致。
    /// - Note: 起止日期缺失时无法计算，按 0 计（等价于时间尚未推进）；
    ///         起止日期相同或倒置时视为已到期。
    private var timeProgress: Double {
        guard let startDate = startDate, let endDate = endDate else {
            return 0
        }
        
        let span = endDate.timeIntervalSince(startDate)
        let elapsed = Date().timeIntervalSince(startDate)
        if span > 0 {
            return min(max(elapsed / span, 0), 1)
        }
        
        // 起止日期相同或倒置：视为已到期。
        return elapsed >= 0 ? 1 : 0
    }
}

extension Array where Element == GoalPlan {
    
    /// 所有标识
    var identifiers: [String] {
        return self.map { $0.identifier }
    }
}
