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
}

class GoalPlan: NSObject, SortableIdentifiable {
    
    /// 目标唯一标识
    var identifier: String
    
    /// 排序因子
    var order: Int64
    
    /// 目标名称
    var name: String?
    
    /// 目标颜色
    var color: UIColor
    
    /// 开始日期
    var startDate: Date?
    
    /// 结束日期
    var endDate: Date?
    
    /// 备注
    var note: String?
    
    /// 是否已归档
    var isArchived: Bool
    
    /// 修改日期
    let modificationDate: Date?
    
    init(identifier: String = UUID().uuidString,
         order: Int64 = 0,
         name: String? = nil,
         color: UIColor = GoalConfig.goalPlanDefaultColor,
         startDate: Date? = nil,
         endDate: Date? = nil,
         note: String? = nil,
         isArchived: Bool = false,
         modificationDate: Date? = nil) {
        self.identifier = identifier
        self.order = order
        self.name = name
        self.color = color
        self.startDate = startDate
        self.endDate = endDate
        self.note = note
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
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? GoalPlan else { return false }
        if self === other { return true }
        return editingPlan == other.editingPlan
    }
    
    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let other = object as? GoalPlan {
            return self.identifier == other.identifier
        }
        
        return false
    }
}

struct GoalEditingPlan: Equatable {
    
    var name: String?
    
    var color: UIColor = GoalConfig.goalPlanDefaultColor

    var startDate: Date?
    
    var endDate: Date?
    
    var note: String?
    
    static func == (lhs: GoalEditingPlan, rhs: GoalEditingPlan) -> Bool {
        return lhs.name == rhs.name
            && lhs.color == rhs.color
            && lhs.startDate == rhs.startDate
            && lhs.endDate == rhs.endDate
            && lhs.note == rhs.note
    }
    
    var dateRange: DateRange {
        get {
            let start = startDate ?? .now.startOfDay()
            let end: Date
            if let date = endDate, date > start {
                end = date
            } else {
                let date = start.dateByAddingMonths(1) ?? start
                end = date.endOfDay()
            }
            
            return DateRange(startDate: start, endDate: end)
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
        var plan = GoalEditingPlan()
        plan.name = name
        plan.color = color
        plan.startDate = startDate
        plan.endDate = endDate
        plan.note = note
        return plan
    }
    
    /// 判断编辑内容是否与当前目标相同
    func isSamePlan(as editingPlan: GoalEditingPlan) -> Bool {
        let current = self.editingPlan
        return current == editingPlan
    }
}

extension Array where Element == GoalPlan {
    
    /// 所有标识
    var identifiers: [String] {
        return self.map { $0.identifier }
    }
}
