//
//  WSCountdownRecentCardContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 卡片风格

/// 倒数日「最近」类组件的卡片风格。
///
/// 卡片底色很淡，只比组件背景略亮一点；骨架块颜色比全局默认更明显，
/// 保证在淡底色卡片上仍能看出层次。字段均有默认值，按需覆盖即可。
struct WSCountdownRecentCardStyle {
    
    /// 卡片底色
    var backColor: UIColor = Color(light: 0x000000, 0.05, dark: 0xFFFFFF, 0.10)
    
    /// 卡片按下时的底色
    var highlightedBackColor: UIColor = Color(light: 0x000000, 0.10, dark: 0xFFFFFF, 0.20)
    
    /// 卡片圆角
    var cornerRadius: CGFloat = 12.0
    
    /// 卡片骨架配置
    var skeletonConfig: SkeletonConfig = {
        var config = Skeleton.config
        config.baseColor = Color(light: 0x000000, 0.12, dark: 0xFFFFFF, 0.22)
        return config
    }()
}

// MARK: - 内容视图

/// 倒数日「最近」卡片内容视图。
///
/// 多列等分的卡片网格，行视图默认使用横排简略样式（图标 + 名称 + 剩余时间），
/// 窄列场景可传入竖排样式等其它行视图。
class WSCountdownRecentCardContentView: WSCountdownRecentContentView {
    
    /// 卡片内边距
    private static let contentInsets = UIEdgeInsets(value: 8.0)
    
    /// 卡片间距
    private static let spacing: CGFloat = 8.0
    
    /// 初始化内容视图
    /// - Parameters:
    ///   - itemCount: 卡片数量，与交互器最多展示的事项数目保持一致
    ///   - columnCount: 每行卡片数
    ///   - cardStyle: 卡片风格
    ///   - makeRowView: 卡片视图的构建闭包
    init(itemCount: Int,
         columnCount: Int,
         cardStyle: WSCountdownRecentCardStyle = WSCountdownRecentCardStyle(),
         makeRowView: () -> WSCountdownEventRowBaseView = { WSCountdownCompactEventRowView() }) {
        super.init(itemCount: itemCount,
                   columnCount: columnCount,
                   contentInsets: WSCountdownRecentCardContentView.contentInsets,
                   spacing: WSCountdownRecentCardContentView.spacing,
                   cardStyle: cardStyle,
                   makeRowView: makeRowView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
