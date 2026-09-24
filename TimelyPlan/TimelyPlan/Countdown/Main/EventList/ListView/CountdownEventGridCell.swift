//
//  CountdownEventGridCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/17.
//

import Foundation
import UIKit

protocol CountdownEventGridCellDelegate: AnyObject {
    /// 点击更多
    func countdownEventGridCellDidClickMore(_ cell: CountdownEventGridCell)
}

/// 倒数日事项网格单元格
class CountdownEventGridCell: TPCollectionCell {
    
    struct Config {
        /// 单元格高度（高于列表行）
        static let cellHeight = 190.0
        /// emoji 图标尺寸
        static let iconSize = CGSize(width: 50.0, height: 50.0)
        /// 更多按钮尺寸
        static let moreButtonSize = CGSize.mini
        /// emoji 与信息视图的间距
        static let iconInfoMargin = 10.0
        /// 信息视图与数值视图的间距
        static let infoValueMargin = 8.0
        /// 数值视图高度
        static let valueHeight = 44.0
    }
    
    /// 倒数日事项
    var event: CountdownEvent? {
        didSet {
            self.updateInfo()
        }
    }
    
    /// emoji 图标视图
    let iconView: TPIconView = {
        let view = TPIconView()
        view.font = UIFont.systemFont(ofSize: 32.0)
        view.backColor = .secondarySystemFill
        return view
    }()
    
    /// 更多按钮
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.imageConfig.color = .secondaryLabel
        button.addTarget(self,
                         action: #selector(clickMore(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    /// 信息视图（标题 + 副标题）
    let infoView: TPInfoView = {
        let view = TPInfoView()
        view.titleConfig.font = .boldSystemFont(ofSize: 16.0)
        view.subtitleTopMargin = 6.0
        return view
    }()
    
    /// 剩余时间视图：数值 + 单位角标，靠左显示
    let valueView: CountdownTimeValueView = {
        let view = CountdownTimeValueView()
        view.textAlignment = .left
        view.textColor = .label
        view.unitColor = .label
        /// 网格单元格空间有限，字号小于详情页
        view.valueFont = .monospacedDigitSystemFont(ofSize: 28.0, weight: .bold)
        view.unitFont = .systemFont(ofSize: 13.0, weight: .medium)
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        
        contentView.padding = UIEdgeInsets(top: 15.0,
                                           left: 16.0,
                                           bottom: 15.0,
                                           right: 12.0)
        contentView.addSubview(iconView)
        contentView.addSubview(moreButton)
        contentView.addSubview(infoView)
        
        contentView.addSubview(valueView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = contentView.layoutFrame()
        
        /// emoji：左上角
        iconView.size = Config.iconSize
        iconView.top = contentFrame.minY
        iconView.left = contentFrame.minX
        iconView.cornerRadius = Config.iconSize.height / 2.0
        
        /// 更多按钮：右上角，与 emoji 同一行
        moreButton.size = Config.moreButtonSize
        moreButton.right = contentFrame.maxX
        moreButton.centerY = iconView.centerY
        
        /// 数值视图：最下方
        valueView.frame = CGRect(x: contentFrame.minX,
                                 y: contentFrame.maxY - Config.valueHeight,
                                 width: contentFrame.width,
                                 height: Config.valueHeight)
        
        /// 信息视图：emoji 下方至数值视图上方
        let infoTop = iconView.bottom + Config.iconInfoMargin
        let infoHeight = max(0.0, valueView.top - Config.infoValueMargin - infoTop)
        infoView.frame = CGRect(x: contentFrame.minX,
                                y: infoTop,
                                width: contentFrame.width,
                                height: infoHeight)
    }
    
    /// 更新信息
    func updateInfo() {
        guard let event = event else {
            return
        }
        
        iconView.icon = TPIcon(text: event.emoji ?? event.type.emoji)
        iconView.backColor = event.color ?? event.type.color
        infoView.title = event.displayName
        
        /// 副标题：由 CountdownEventDetailProvider 统一计算
        infoView.subtitle = CountdownEventDetailProvider.detail(for: event)
        
        /// 剩余数目：由 CountdownCalculator 按事项的时间单位换算为结构化结果后展示
        valueView.result = event.remainingTimeResult
        setNeedsLayout()
    }
    
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        if let delegate = delegate as? CountdownEventGridCellDelegate {
            delegate.countdownEventGridCellDidClickMore(self)
        }
    }
    
}
