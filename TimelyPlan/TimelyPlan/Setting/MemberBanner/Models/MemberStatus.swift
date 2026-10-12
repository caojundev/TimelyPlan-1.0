//
//  MemberStatus.swift
//  MemberBanner
//
//  数据模型层：只描述「要展示什么」，不含任何 UI 代码。
//  这样 View 与业务数据解耦 —— 只要组装出 MemberStatus 就能渲染 Banner。
//

import Foundation

/// 会员类型
enum MembershipTier: String {
    case monthly  = "月度"
    case yearly   = "年度"
    case lifetime = "永久"

    /// 展示用的中文全称
    var displayName: String { rawValue + "会员" }
}

/// 会员状态模型（ViewModel 的输入）
struct MemberStatus {

    /// 昵称
    let nickname: String
    /// 用户 ID
    let uid: String
    /// 是否已验证
    let isVerified: Bool
    /// 会员档位
    let tier: MembershipTier

    /// 有效期文案。永久会员无到期日，传 nil 即可。
    /// 例如 "2027.03.15"
    let expireDateText: String?
    /// 剩余天数文案，例如 "剩余 519 天"；永久会员传 nil。
    let remainingDaysText: String?
    /// 权益是否全部解锁
    let isAllUnlocked: Bool

    // MARK: - 派生展示文案（把「怎么拼字」收敛到模型，View 只负责排版）

    /// 卡片主标题：「尊享会员 · 年度」
    var cardTitle: String {
        "尊享会员 · \(tier.rawValue)"
    }

    /// 卡片副标题：「有效期至 2027.03.15 · 剩余 519 天」
    /// 永久会员展示为「终身有效 · 永久权益」
    var cardSubtitle: String {
        if tier == .lifetime {
            return "终身有效 · 永久权益"
        }
        var parts: [String] = []
        if let expireDateText = expireDateText { parts.append("有效期至 \(expireDateText)") }
        if let remainingDaysText = remainingDaysText { parts.append(remainingDaysText) }
        return parts.joined(separator: " · ")
    }

    /// 权益状态文案
    var unlockText: String {
        isAllUnlocked ? "权益已全部解锁" : "部分权益待解锁"
    }

    /// UID 展示文案
    var uidText: String {
        isVerified ? "UID \(uid) · 已验证" : "UID \(uid)"
    }
}

// MARK: - 便捷构造（示例数据）
extension MemberStatus {
    static func sample() -> MemberStatus {
        MemberStatus(
            nickname: "Alex Chen",
            uid: "8823 1947",
            isVerified: true,
            tier: .yearly,
            expireDateText: "2027.03.15",
            remainingDaysText: "剩余 519 天",
            isAllUnlocked: true
        )
    }
}
