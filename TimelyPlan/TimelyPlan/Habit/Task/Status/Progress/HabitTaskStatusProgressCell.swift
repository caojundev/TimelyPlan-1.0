//
//  HabitTaskStatusProgressCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/29.
//

import Foundation
import UIKit

/// 习惯任务状态进度单元格
class HabitTaskStatusProgressCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    /// 进度尺寸
    var statusProgressSize = CGSize(width: 42.0, height: 42.0)

    /// 状态进度视图
    let statusProgressView = HabitTaskStatusProgressView()
    
    var progressView: TPCircleOutlineProgressView {
        return statusProgressView.progressView
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
        setupBackgroundViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutStatusProgressView()
        updateBackgroundViewAppearance()
    }
    
    // MARK: - Setup Methods
    
    /// 设置内容视图
    private func setupContentView() {
        contentView.padding = UIEdgeInsets(horizontal: 5.0)
        contentView.addSubview(statusProgressView)
    }
    
    /// 设置背景视图
    private func setupBackgroundViews() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(white: 0.6, alpha: 0.1)
        self.backgroundView = backgroundView
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(white: 0.6, alpha: 0.2)
        self.selectedBackgroundView = selectedBackgroundView
    }
    
    /// 布局状态进度视图
    private func layoutStatusProgressView() {
        statusProgressView.frame = statusProgressFrame()
    }
    
    /// 更新背景视图外观
    private func updateBackgroundViewAppearance() {
        let cornerRadius = statusProgressView.frame.boundingCornerRadius
        backgroundView?.frame = statusProgressView.frame
        backgroundView?.layer.cornerRadius = cornerRadius
        selectedBackgroundView?.frame = statusProgressView.frame
        selectedBackgroundView?.layer.cornerRadius = cornerRadius
    }
    
    // MARK: - Frame Calculation
    
    /// 计算背景视图区域
    func statusProgressFrame() -> CGRect {
        let layoutFrame = contentView.layoutFrame()
        let x = layoutFrame.minX + (layoutFrame.width - statusProgressSize.width) / 2.0
        return CGRect(x: x, y: layoutFrame.minY, size: statusProgressSize)
    }
}
