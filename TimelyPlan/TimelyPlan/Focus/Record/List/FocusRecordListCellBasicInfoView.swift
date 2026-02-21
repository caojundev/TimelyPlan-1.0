//
//  FocusRecordListCellBasicInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/21.
//

import Foundation
import UIKit

/// 专注记录列表单元格基础模式信息视图
class FocusRecordListCellBasicInfoView: FocusRecordListCellBaseInfoView {
    
    /// 会话时长标签
    private lazy var durationLabel: TPLabel = {
        let label = TPLabel()
        label.font = SMALL_SYSTEM_FONT
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(durationLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutComponents() {
        super.layoutComponents()
        
        let layoutFrame = layoutFrame()
        
        // 布局更多按钮
        moreButton.size = moreButtonSize
        moreButton.right = layoutFrame.maxX
        moreButton.centerY = layoutFrame.minY + rangeLabelHeight / 2.0
        
        // 布局会话时长标签（在更多按钮左侧）
        durationLabel.sizeToFit()
        durationLabel.right = moreButton.left - 8.0  // 8pt 间距
        durationLabel.centerY = moreButton.centerY
        
        // 布局日期范围标签（为时长标签留出空间）
        let availableWidth = layoutFrame.width - moreButtonSize.width - durationLabel.width - 8.0
        dateRangeLabel.width = availableWidth
        dateRangeLabel.height = rangeLabelHeight
        dateRangeLabel.origin = layoutFrame.origin

        // 布局计时器信息视图
        timerInfoView.width = layoutFrame.width / 2.0
        timerInfoView.height = infoViewHeight
        timerInfoView.top = dateRangeLabel.bottom
        timerInfoView.left = layoutFrame.minX
    }
    
    override func reloadData(with session: FocusSession) {
        super.reloadData(with: session)
        
        // 更新会话时长
        let duration = Duration(session.duration)
        durationLabel.attributed.text = duration.attributedTitle()
        /// 重新布局
        self.setNeedsLayout()
    }
}
