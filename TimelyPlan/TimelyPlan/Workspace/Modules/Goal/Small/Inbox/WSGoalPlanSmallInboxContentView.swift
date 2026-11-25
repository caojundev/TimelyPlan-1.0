//
//  WSGoalPlanSmallInboxContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 目标·小·收件箱的内容视图。
///
/// 左上角为收件箱图标，其下方为名称与任务数目，任务数目以大字号贴左下角展示。
class WSGoalPlanSmallInboxContentView: WSPluginContentView {
    
    /// 布局比例。图标下方区域均以剩余高度为基准，避免固定尺寸在不同设备上错位。
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 12.0)
        
        /// 图标尺寸
        static let iconSize = CGSize(width: 50.0, height: 50.0)
        
        /// 信息视图占剩余高度的比例
        static let infoHeight: CGFloat = 0.4
        
        /// 任务数目占剩余高度的比例
        static let valueHeight: CGFloat = 0.5
        
        /// 图标、信息视图、任务数目之间的间距占剩余高度的比例
        static let contentSpacing: CGFloat = 0.05
        
        /// 任务数目字号占数值区域高度的比例
        static let valueFont: CGFloat = 0.8
    }
    
    /// 图标
    private lazy var iconView: TPIconView = {
        let view = TPIconView()
        view.icon = TPIcon(name: "inbox_24")
        view.foreColor = .white
        view.backColor = .primary
        view.cornerRadius = .greatestFiniteMagnitude
        return view
    }()
    
    /// 信息视图
    private lazy var infoView: TPInfoView = {
        let view = TPInfoView()
        view.title = resGetString("Goal Inbox")
        return view
    }()
    
    /// 任务数目
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        
        addSubview(iconView)
        addSubview(infoView)
        addSubview(countLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        guard layoutFrame.width > 0.0, layoutFrame.height > 0.0 else {
            return
        }
        
        /// 图标贴左上
        iconView.size = Metrics.iconSize
        iconView.origin = layoutFrame.origin
        
        /// 图标下方剩余高度按比例分配给信息视图与任务数目
        let contentHeight = max(layoutFrame.height - Metrics.iconSize.height, 0.0)
        let spacing = contentHeight * Metrics.contentSpacing
        
        infoView.width = layoutFrame.width
        infoView.height = contentHeight * Metrics.infoHeight
        infoView.left = layoutFrame.minX
        infoView.top = iconView.bottom + spacing
        
        let valueHeight = contentHeight * Metrics.valueHeight
        countLabel.width = layoutFrame.width
        countLabel.height = valueHeight
        countLabel.left = layoutFrame.minX
        countLabel.top = infoView.bottom + spacing
        
        /// 字号按数值区域高度换算，保证数目始终填满该区域
        let valueFontSize = max(floor(valueHeight * Metrics.valueFont), 1.0)
        countLabel.font = UIFont.monospacedDigitSystemFont(ofSize: valueFontSize, weight: .bold)
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem as? WSGoalPlanInboxDataItem else {
            countLabel.text = nil
            setNeedsLayout()
            return
        }
        
        countLabel.text = "\(dataItem.taskCount)"
        setNeedsLayout()
    }
}
