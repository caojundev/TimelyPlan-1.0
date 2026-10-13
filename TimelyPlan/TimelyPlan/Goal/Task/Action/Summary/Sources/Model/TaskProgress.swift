import Foundation

/// 一个目标任务的原始数据。
///
/// 只承载数据，不做任何进度计算 —— 所有推导逻辑都放在 `ProgressCalculator`，
/// 因此本类型可以脱离 UIKit 单独测试。
struct TaskProgress {

    /// 起始值，即计划开始时的已完成数量。
    let initialValue: Int

    /// 计划开始日期。
    let startDate: Date

    /// 计划截止日期。
    let endDate: Date

    /// 已完成的任务项数量。
    let completedCount: Int

    /// 任务项总数。
    let totalCount: Int

    init(initialValue: Int,
         startDate: Date,
         endDate: Date,
         completedCount: Int,
         totalCount: Int) {
        self.initialValue = initialValue
        self.startDate = startDate
        self.endDate = endDate
        self.completedCount = completedCount
        self.totalCount = totalCount
    }
}
