//
//  MemberBannerTheme.swift
//  MemberBanner
//
//  设计令牌（Design Tokens）—— 唯一的设计常量来源。
//  整个 Banner 的所有颜色、字号、间距、圆角都从这里取，禁止在 View 中硬编码数值。
//

import UIKit

/// 颜色令牌。浅色主题下的「黑金」配色。
enum MemberBannerTheme {

    enum Color {
        // MARK: 金色体系
        static let goldLight    = UIColor(hex: 0xF3DFA8)     // 徽标亮金
        static let goldDeep     = UIColor(hex: 0xC9A154)     // 描边 / 图标
        static let goldInk      = UIColor(hex: 0x2A2011)     // 金底上的文字

        // MARK: 卡片（深色小金卡）
        static let cardTop      = UIColor(hex: 0x241E15)
        static let cardMid      = UIColor(hex: 0x191510)
        static let cardBottom   = UIColor(hex: 0x121010)
        static let cardInnerLine = UIColor(hex: 0xE8C77E, alpha: 0.18)
        static let cardTitle    = UIColor(hex: 0xFBF1D6)     // 金卡标题渐变起点
        static let cardTitleEnd = UIColor(hex: 0xE2C180)     // 金卡标题渐变终点
        static let cardSubtitle = UIColor(hex: 0x958E7D)     // 金卡副文案
        static let cardBodyText = UIColor(hex: 0xB3AA92)     // 金卡正文
        static let cardLinkText = UIColor(hex: 0xE0C88E)     // 金卡「查看权益」
}

    /// 字号令牌。标题走衬线体，正文走系统无衬线体，形成尊贵感层次。
    enum Font {
        static func serif(_ size: CGFloat) -> UIFont {
            let base = UIFont.systemFont(ofSize: size, weight: .semibold)
            guard let d = base.fontDescriptor.withDesign(.serif) else { return base }
            return UIFont(descriptor: d, size: size)
        }
        static func sans(_ size: CGFloat, _ weight: UIFont.Weight = .regular) -> UIFont {
            UIFont.systemFont(ofSize: size, weight: weight)
        }
    }
}
