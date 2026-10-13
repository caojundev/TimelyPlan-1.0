import Foundation

/// 一个目标任务的原始数据。
///
/// 只承载数据，不做任何进度计算 —— 所有推导逻辑都放在 `GoalSummaryCalculator`，
/// 因此本类型可以脱离 UIKit 单独测试。
struct GoalSummaryTask {

    /// 起始值，即计划开始时的数值。允许大于 `targetValue`（递减型目标，如「100 → 20」）。
    let initialValue: Int

    /// 计划开始日期。
    let startDate: Date

    /// 计划截止日期。
    let endDate: Date

    /// 当前数值。
    let currentValue: Int

    /// 目标数值。递减型目标时小于 `initialValue`。
    let targetValue: Int

    init(initialValue: Int,
         startDate: Date,
         endDate: Date,
         currentValue: Int,
         targetValue: Int) {
        self.initialValue = initialValue
        self.startDate = startDate
        self.endDate = endDate
        self.currentValue = currentValue
        self.targetValue = targetValue
    }
}
