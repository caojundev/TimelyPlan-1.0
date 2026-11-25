//
//  WSMyDayDetailAllDayEventRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 详细行视图

/// 全天事项详细行视图，供中、大尺寸组件使用。
///
/// 左侧为与 `MyDayTimelineView` 节点一致的图标：事项颜色作为底色，
/// 图标按事项来源展示；右侧为事项名称。行高由外部决定。
class WSMyDayDetailAllDayEventRowView: WSMyDayAllDayEventRowBaseView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与行边缘的间距
        static let contentInsets = UIEdgeInsets(left: 4.0, right: 4.0)
        
        /// 图标边长及与名称的间距
        static let iconSide: CGFloat = 24.0
        static let iconTitleSpacing: CGFloat = 10.0
        
        /// 图标字号，用于展示表情类图标
        static let iconFont = UIFont.systemFont(ofSize: 12.0)
        
        /// 名称字体
        static let titleFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
    }
    
    /// 类型图标
    private let iconView = TPIconView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.contentInsets
        self.titleLabel.font = Metrics.titleFont
        
        iconView.borderWidth = 0.0
        iconView.foreColor = .white
        iconView.font = Metrics.iconFont
        addSubview(iconView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var accessoryTitleSpacing: CGFloat {
        return Metrics.iconTitleSpacing
    }
    
    // MARK: - 布局
    override func layoutAccessory(in contentFrame: CGRect) -> CGFloat {
        /// 图标靠左垂直居中，行高不足时随行高缩小
        let iconSide = min(Metrics.iconSide, contentFrame.height)
        iconView.size = CGSize(width: iconSide, height: iconSide)
        iconView.left = contentFrame.minX
        iconView.centerY = contentFrame.midY
        iconView.cornerRadius = iconSide / 2.0
        
        return iconView.right
    }
    
    // MARK: - 渲染
    override func reloadAccessory() {
        iconView.icon = dataItem?.sourceIcon
        iconView.backColor = dataItem?.color ?? .clear
        iconView.foreColor = .white
    }
}
