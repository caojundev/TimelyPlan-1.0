//
//  WSCountdownPluginContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 倒数日组件内容视图
class WSCountdownPluginContentView: WSPluginContentView {
    
    /// 布局比例。均以组件短边为基准，避免固定尺寸在不同设备上错位。
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 12.0)
        
        /// emoji 图标尺寸
        static let iconSize = CGSize(width: 50.0, height: 50.0)

        static let iconFont = UIFont.boldSystemFont(ofSize: 25.0)
        
        static let valueHeight = 0.4
        
        static let infoHeight = 0.5
        
        /// 图标与名称的间距
        static let iconTitleSpacing: CGFloat = 0.05

        /// 信息视图与剩余时间的间距
        static let infoValueSpacing: CGFloat = 0.05
        
        /// 数值字号占剩余时间区域高度的比例
        static let valueFont: CGFloat = 0.8
        
        /// 单位字号占数值字号的比例
        static let unitFont: CGFloat = 0.40
        
        /// 「今天」字号占数值字号的比例
        static let todayFont: CGFloat = 0.6
    }
    
    /// 事项图标
    private let iconView = TPIconView()
    
    /// 信息视图
    private let infoView = TPInfoView()
    
    /// 数值视图
    private let valueView = CountdownTimeValueView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        iconView.font = Metrics.iconFont
        iconView.cornerRadius = .greatestFiniteMagnitude
        addSubview(iconView)
        addSubview(infoView)
        
        valueView.textAlignment = .left
        valueView.glowColor = .clear
        addSubview(valueView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = bounds.inset(by: Metrics.padding)
        iconView.size = Metrics.iconSize
        iconView.origin = layoutFrame.origin
        
        let contentHeight = layoutFrame.height - Metrics.iconSize.height
        infoView.width = layoutFrame.width
        infoView.height = contentHeight * Metrics.infoHeight
        infoView.left = layoutFrame.minX
        infoView.top = iconView.bottom + contentHeight * Metrics.iconTitleSpacing
        
        let valueHeight = contentHeight * Metrics.valueHeight
        valueView.width = layoutFrame.width
        valueView.height = valueHeight
        valueView.left = layoutFrame.minX
        valueView.top = infoView.bottom + contentHeight * Metrics.infoValueSpacing
        
        /// 字号按剩余时间区域高度换算，保证数值始终填满该区域且不被裁切；
        /// 数值宽度超出时由 `CountdownTimeValueView` 自身的 adjustsFontSizeToFitWidth 缩放
        let valueFontSize = floor(valueHeight * Metrics.valueFont)
        valueView.valueFont = UIFont.monospacedDigitSystemFont(ofSize: valueFontSize, weight: .heavy)
        valueView.unitFont = UIFont.systemFont(ofSize: floor(valueFontSize * Metrics.unitFont), weight: .medium)
        valueView.todayFont = UIFont.systemFont(ofSize: floor(valueFontSize * Metrics.todayFont), weight: .bold)
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        guard let dataItem = dataItem as? WSCountdownDataItem else {
            showEmptyState()
            return
        }
        
        iconView.isHidden = false
        infoView.isHidden = false
        valueView.isHidden = false
        iconView.icon = TPIcon(text: dataItem.emoji)
        iconView.backColor = dataItem.color
        infoView.title = dataItem.title
        infoView.subtitle = dataItem.dateText
        
        /// 组件为浅色背景，数值使用常规文本色，单位弱化；光晕与详情页一致取事项主题色
        valueView.textColor = .label
        valueView.unitColor = .secondaryLabel
        valueView.result = dataItem.timeResult
        
        setNeedsLayout()
    }
    
    private func showEmptyState() {
        iconView.isHidden = true
        infoView.isHidden = true
        valueView.isHidden = true
        
        iconView.icon = nil
        infoView.title = nil
        infoView.subtitle = nil
        valueView.result = nil
    }
}
