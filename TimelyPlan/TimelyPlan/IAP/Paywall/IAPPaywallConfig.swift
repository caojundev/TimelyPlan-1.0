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
    /// 元组顺序：(权益名称, 普通用户列, 高级会员列)；
    /// 取值可用 `.text("基础", color: .systemRed)` 或 `.icon("checkmark", color: .systemGreen)`，
    /// 不传 color（或用 `nil`）时使用所在列的默认颜色。
    static let benefitRows: [IAPMembershipBenefitRowTuple] = [
        // 文本 + 文本
        ("日历视图", .text("基础"), .text("月/周/日/3日")),
        // 文本 + 文本（自定义颜色）
        ("文本颜色（红/绿）", .text("基础", color: .systemRed), .text("无限制", color: .systemGreen)),
        // 文本自定义色 + 默认色
        ("文本颜色（橙/默认）", .text("基础", color: .systemOrange), .text("无限制")),
        // 占位符 + 图标
        ("时间段", nil, .icon("checkmark")),
        ("持续提醒", nil, .icon("checkmark")),
        // 图标 + 图标（使用列默认颜色）
        ("关联 Notion", .icon("xmark_16"), .icon("checkmark")),
        ("关联微信", .icon("xmark_16"), .icon("checkmark")),
        ("AI 语音添加", .icon("xmark_16"), .icon("checkmark")),
        // 图标 + 图标（自定义颜色）
        ("颜色测试（红/绿）",
         .icon("xmark_16", color: .systemRed),
         .icon("checkmark_circle_fill_24", color: .systemGreen)),
        // 图标自定义色 + 默认色
        ("颜色测试（橙/默认）", .icon("xmark", color: .systemOrange), .icon("checkmark")),
        // 图标 + 文本
        ("AI 录音总结", .icon("xmark"), .text("无限制")),
        // 文本 + 图标
        ("小组件", .text("基础"), .icon("checkmark")),
        ("外观主题", .text("基础"), .text("无限制")),
        // 文本 + 文本
        ("数据统计", .text("基础"), .text("无限制")),
        // 占位符 + 图标
        ("更多功能", nil, .icon("checkmark_circle_fill_24")),
    ]
}
