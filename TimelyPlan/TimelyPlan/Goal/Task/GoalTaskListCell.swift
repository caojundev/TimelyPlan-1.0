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

class GoalTaskListCell: TPDefaultInfoCollectionCell {
    
    /// 目标任务
    var goalTask: GoalTask? {
        didSet {
            self.updateInfo()
        }
    }
    
    let kInfoViewMargin = 10.0
    
    /// 权重指示器尺寸
    let kIndicatorSize = CGSize(width: 6.0, height: 36.0)
    
    /// 权重指示器
    lazy var indicatorView: UIView = {
        let view = UIView()
        view.size = kIndicatorSize
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
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.contentView.padding = UIEdgeInsets(top: 5.0, left: 16.0, bottom: 5.0, right: 10.0)
        contentView.addSubview(indicatorView)
        contentView.addSubview(moreButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        
        indicatorView.size = kIndicatorSize
        indicatorView.left = layoutFrame.minX
        indicatorView.alignVerticalCenter()
        
        moreButton.sizeToFit()
        moreButton.right = layoutFrame.maxX
        moreButton.alignVerticalCenter()
        
        infoView.width = layoutFrame.width - indicatorView.width - moreButton.width - kInfoViewMargin * 2
        infoView.height = layoutFrame.height
        infoView.left = indicatorView.right + kInfoViewMargin
        infoView.top = layoutFrame.minY
    }
    
    /// 更新信息
    func updateInfo() {
        guard let goalTask = goalTask else {
            return
        }
        
        indicatorView.backgroundColor = .primary
        
        /// 标题：目标任务数值进度
        let title = "\(goalTask.initialValue)/\(goalTask.targetValue)"
        infoView.title = title
        
        /// 副标题：记录方式、计算方式与权重
        var subtitleComponents = [ASAttributedString]()
        subtitleComponents.append(goalTask.recordType.title.attributedString)
        subtitleComponents.append(goalTask.calculation.title.attributedString)
        if goalTask.weight > 0 {
            let weightText = String(format: resGetString("Weight %ld"), goalTask.weight)
            subtitleComponents.append(weightText.attributedString)
        }
        
        infoView.subtitle = subtitleComponents.joined(separator: " • ")
    }
    
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        if let delegate = delegate as? GoalTaskListCellDelegate {
            delegate.goalTaskListCellDidClickMore(self)
        }
    }
}
