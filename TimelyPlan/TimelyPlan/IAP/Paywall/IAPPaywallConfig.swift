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
    static let benefitsTitleHighlight = "10+"

    /// 权益对比行
    ///
    /// 元组顺序：(权益名称, 普通用户列, 高级会员列)
    static let benefitRows: [IAPMembershipBenefitRowTuple] = [
        ("日历视图", .basicText, .text("月/周/日/3日")),
        ("文本颜色（红/绿）", nil, .unlimitedText),
        ("文本颜色（橙/默认）", nil, .unlimitedText),
        ("时间段", nil, .checkmark),
        ("持续提醒", nil, .checkmark),
        ("关联 Notion", nil, .checkmark),
        ("关联微信", nil, .checkmark),
        ("AI 语音添加", nil, .checkmark),
        ("颜色测试（红/绿）", nil, .checkmark),
        ("颜色测试（橙/默认）", .basicText, .checkmark),
        ("AI 录音总结", nil, .unlimitedText),
        ("小组件", .basicText, .checkmark),
        ("外观主题", .basicText, .unlimitedText),
        ("数据统计", .basicText, .unlimitedText),
        ("更多功能", nil, .checkmark),
    ]
}
