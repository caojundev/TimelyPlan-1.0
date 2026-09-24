//
//  CountdownEventListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation
import UIKit

protocol CountdownEventListCellDelegate: AnyObject {
    /// 点击更多
    func countdownEventListCellDidClickMore(_ cell: CountdownEventListCell)
}

class CountdownEventCellStyle: TPCollectionCellStyle {
    
    override init() {
        super.init()
        self.backgroundColor = .secondarySystemGroupedBackground
        self.selectedBackgroundColor = .tertiarySystemGroupedBackground
        self.cornerRadius = 12.0
    }
}

class CountdownEventListCell: TPCollectionCell {
    
    /// 单元格默认高度
    static let cellHeight = 90.0
    
    /// 数值视图最大宽度
    private let valueViewMaximumWidth: CGFloat = 80.0
    
    /// 数值视图与更多按钮的间距
    private let valueMoreMargin: CGFloat = 8.0
    
    /// 信息视图与数值视图的间距
    private let infoValueMargin: CGFloat = 8.0
    
    /// 倒数日事项
    var event: CountdownEvent? {
        didSet {
            self.updateInfo()
        }
    }
    
    /// 信息视图
    let infoView = CountdownEventListInfoView()
    
    /// 数值视图（显示剩余数目）
    let valueView: CountdownVerticalValueView = {
        let view = CountdownVerticalValueView()
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
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        
        contentView.padding = UIEdgeInsets(top: 15.0,
                                           left: 16.0,
                                           bottom: 15.0,
                                           right: 12.0)
        contentView.addSubview(infoView)
        contentView.addSubview(valueView)
        contentView.addSubview(moreButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = contentView.layoutFrame()
        
        /// 更多按钮：靠右、垂直居中
        moreButton.size = .mini
        moreButton.right = contentFrame.maxX
        moreButton.centerY = contentFrame.midY
        
        /// 数值视图：位于更多按钮左侧，宽度按内容自适应并限制最大宽度，高度撑满内容区
        let availableValueWidth = max(0.0, moreButton.left - valueMoreMargin - contentFrame.minX)
        let valueFitSize = valueView.sizeThatFits(CGSize(width: availableValueWidth,
                                                         height: contentFrame.height))
        let valueWidth = min(valueFitSize.width, valueViewMaximumWidth, availableValueWidth)
        valueView.frame = CGRect(x: moreButton.left - valueMoreMargin - valueWidth,
                                 y: contentFrame.minY,
                                 width: valueWidth,
                                 height: contentFrame.height)
        
        /// 信息视图：占据左侧剩余空间
        let infoWidth = max(0.0, valueView.left - infoValueMargin - contentFrame.minX)
        infoView.frame = CGRect(x: contentFrame.minX,
                                y: contentFrame.minY,
                                width: infoWidth,
                                height: contentFrame.height)
    }
    
    /// 更新信息
    func updateInfo() {
        guard let event = event else {
            return
        }
        
        infoView.icon = TPIcon(text: event.emoji ?? event.type.emoji)
        infoView.iconBackColor = event.color ?? event.type.color
        infoView.title = event.displayName
        
        /// 副标题：由 CountdownEventDetailProvider 统一计算（目标日期 + 剩余天数）
        infoView.subtitle = CountdownEventDetailProvider.detail(for: event)
        
        /// 剩余数目：由 CountdownCalculator 按事项的时间单位换算为结构化结果后展示
        valueView.setResult(event.remainingTimeResult)
        
        /// 数值视图宽度随内容变化，需重新布局
        setNeedsLayout()
    }
    
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        if let delegate = delegate as? CountdownEventListCellDelegate {
            delegate.countdownEventListCellDidClickMore(self)
        }
    }
}

/// 倒数日事项信息视图（左配件为表情图标）
class CountdownEventListInfoView: TPInfoView {
    
    /// 图标尺寸
    let iconSize = CGSize(width: 50.0, height: 50.0)
    
    /// 图标
    var icon: TPIcon? {
        get {
            return iconView.icon
        }
        
        set {
            iconView.icon = newValue
        }
    }
    
    var iconBackColor: UIColor? {
        get {
            return iconView.backColor
        }
        
        set {
            iconView.backColor = newValue
        }
    }
    
    /// 图标视图
    private lazy var iconView: TPIconView = {
        let view = TPIconView()
        view.font = UIFont.systemFont(ofSize: 32.0)
        view.backColor = .secondarySystemFill
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        titleConfig.font = .boldSystemFont(ofSize: 16.0)
        subtitleTopMargin = 8.0
        leftAccessoryView = iconView
        leftAccessorySize = iconSize
        leftAccessoryMargins = UIEdgeInsets(right: 12.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconView.cornerRadius = iconSize.height / 2.0
    }
}
