//
//  GoalTaskListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/2.
//

import Foundation
import UIKit

protocol GoalTaskListCellDelegate: AnyObject {
    
    /// 点击更多
    func goalTaskListCellDidClickMore(_ cell: GoalTaskListCell)
}

class GoalTaskCellStyle: TPCollectionCellStyle {
    
    override init() {
        super.init()
        self.backgroundColor = .secondarySystemGroupedBackground
        self.selectedBackgroundColor = .tertiarySystemGroupedBackground
        self.cornerRadius = 12.0
    }
}

class GoalTaskListCell: TPCollectionCell {
    
    /// 任务布局对象
    var layout: GoalTaskInfoLayout?
    
    /// 目标任务
    var goalTask: GoalTask? {
        return layout?.task
    }
    
    /// 信息视图
    let infoView = GoalTaskInfoView()
    
    /// 权重指示器
    lazy var indicatorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = kIndicatorSize.width / 2.0
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
    
    /// 权重指示器尺寸
    let kIndicatorSize = CGSize(width: 6.0, height: 36.0)
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(indicatorView)
        contentView.addSubview(infoView)
        contentView.addSubview(moreButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let layout = layout else {
            return
        }
        
        let config = layout.config
        contentView.padding = config.padding
        let layoutFrame = contentView.layoutFrame()
        
        indicatorView.size = config.indicatorSize
        indicatorView.left = layoutFrame.minX + config.indicatorMargins.left
        indicatorView.centerY = layoutFrame.midY
        
        moreButton.size = config.moreButtonSize
        moreButton.right = layoutFrame.maxX - config.moreButtonMargins.right
        moreButton.centerY = layoutFrame.midY
        
        let indicatorLength = config.indicatorSize.width + config.indicatorMargins.horizontalLength
        let moreButtonLength = config.moreButtonSize.width + config.moreButtonMargins.horizontalLength
        infoView.frame = CGRect(x: layoutFrame.minX + indicatorLength,
                                y: layoutFrame.minY,
                                width: layoutFrame.width - indicatorLength - moreButtonLength,
                                height: layoutFrame.height)
    }
    
    /// 重新加载数据
    func reloadData(animated: Bool) {
        guard let layout = layout else {
            return
        }
        
        indicatorView.backgroundColor = .primary
        infoView.updateContent(with: layout, animated: animated)
        setNeedsLayout()
    }
    
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        if let delegate = delegate as? GoalTaskListCellDelegate {
            delegate.goalTaskListCellDidClickMore(self)
        }
    }
}
