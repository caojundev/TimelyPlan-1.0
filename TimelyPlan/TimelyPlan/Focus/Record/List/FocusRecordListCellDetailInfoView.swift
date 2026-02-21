//
//  FocusRecordListCellDetailInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/21.
//

import Foundation
import UIKit

/// 专注记录列表单元格详情模式信息视图
class FocusRecordListCellDetailInfoView: FocusRecordListCellBaseInfoView {
    
    /// 手动创建标识相关颜色
    private let manualColor: UIColor = .primary
    
    /// 手动创建标识标签
    private lazy var manualLabel: TPLabel = {
        let label = TPLabel()
        label.font = UIFont.systemFont(ofSize: 8.0)
        label.textColor = .white
        label.layer.backgroundColor = manualColor.cgColor
        label.text = resGetString("Manual")
        label.textAlignment = .center
        label.edgeInsets = UIEdgeInsets(horizontal: 6.0, vertical: 4.0)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(manualLabel)
        setManualLabelHidden(true)
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
        
        // 布局手动标签
        manualLabel.sizeToFit()
        manualLabel.right = moreButton.left
        manualLabel.centerY = moreButton.centerY
        manualLabel.layer.cornerRadius = manualLabel.halfHeight
        
        // 布局日期范围标签（为手动标签留出空间）
        let availableWidth = layoutFrame.width - moreButtonSize.width - manualLabel.width
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
        
        // 更新手动标签显示状态
        setManualLabelHidden(!session.isManual)
    }
    
    /// 设置手动标签隐藏状态
    /// - Parameter isHidden: 是否隐藏
    private func setManualLabelHidden(_ isHidden: Bool) {
        manualLabel.isHidden = isHidden
    }
}