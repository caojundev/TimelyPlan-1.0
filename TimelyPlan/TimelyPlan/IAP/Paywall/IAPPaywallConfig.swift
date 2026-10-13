//
//  IAPPaywallConfig.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/11.
//

import Foundation
import UIKit

/// 付费页配置项：页面文案与权益对比数据集中在此，便于调整
struct IAPPaywallConfig {

    // MARK: - 权益对比

    /// 权益对比标题格式（`%@` 处会用高亮色展示参数）
    static let benefitsTitleFormat = "Enjoy %@ Pro Features"

    /// 标题中高亮展示的参数
    static let benefitsTitleHighlight = "15+"

    /// 权益对比行
    ///
    /// 元组顺序：(权益名称, 普通用户列, 高级会员列)
    static let benefitRows: [IAPMembershipBenefitRowTuple] = [
        // 清单
        (resGetString("List Limit"), .text("5"), .unlimitedText),
        (resGetString("Sub-lists"), .basicText, .checkmark),
        (resGetString("Sub-tasks"), .basicText, .checkmark),
        (resGetString("Filters"), nil, .checkmark),
        (resGetString("Task Progress"), nil, .checkmark),
        (resGetString("Custom Recurrence"), nil, .checkmark),
        (resGetString("Batch Import"), nil, .checkmark),
        (resGetString("Calendar View"), .basicText, .text(resGetString("Week/Month/Quarter/Year"))),
        (resGetString("Custom Quadrants"), nil, .checkmark),

        // 计时器
        (resGetString("Timer Limit"), .text("3"), .unlimitedText),
        (resGetString("Step Timers"), nil, .checkmark),
        (resGetString("Focus Timeline"), nil, .checkmark),

        // 习惯
        (resGetString("Habit Limit"), .text("3"), .unlimitedText),
        (resGetString("Skip/Fail Tags"), nil, .checkmark),
        (resGetString("Habit Report"), nil, .checkmark),

        // 数据统计
        (resGetString("Statistics"), .basicText, .unlimitedText),
    ]
}
