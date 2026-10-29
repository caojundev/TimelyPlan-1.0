//
//  WSGoalTaskBriefRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

// MARK: - 简略行视图

/// 目标任务简略行视图。
///
/// 复用 `GoalTaskCheckInfoView` 展示完成状态、任务名称、日期区间与进度条，
/// 用于小尺寸及后续网格等空间有限的场景，尺寸由外部决定。
class WSGoalTaskBriefRowView: WSGoalTaskRowView {
    
    /// 布局尺寸。整体比目标任务列表更紧凑，适配组件内的行高
    private enum Metrics {
        
        static let checkboxSize = CGSize.size(4)
        
        static let checkboxMargins = UIEdgeInsets(right: 6.0)
        
        /// 名称高度
        static let nameHeight: CGFloat = 17.0
        
        /// 名称与日期的间距
        static let detailTopMargin: CGFloat = 4.0
        
        /// 日期高度
        static let detailHeight: CGFloat = 14.0
        
        /// 日期与进度条的间距
        static let progressTopMargin: CGFloat = 4.0
        
        /// 进度条高度
        static let progressHeight: CGFloat = 3.0
    }
    
    /// 信息视图（完成状态 + 名称 + 日期 + 进度条）。供子类调整尺寸与详情
    let infoView = GoalTaskCheckInfoView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        infoView.checkboxSize = Metrics.checkboxSize
        infoView.checkboxMargins = Metrics.checkboxMargins
        infoView.nameHeight = Metrics.nameHeight
        infoView.detailTopMargin = Metrics.detailTopMargin
        infoView.detailHeight = Metrics.detailHeight
        infoView.progressTopMargin = Metrics.progressTopMargin
        infoView.progressHeight = Metrics.progressHeight
        infoView.nameLabel.font = .boldSystemFont(ofSize: 14.0)
        infoView.nameLabel.numberOfLines = 1
        infoView.detailLabel.font = .systemFont(ofSize: 12.0)
        infoView.detailLabel.adjustsFontSizeToFitWidth = true
        infoView.detailLabel.minimumScaleFactor = 0.8
        infoView.detailLabel.numberOfLines = 1
        
        /// 完成状态自身处理点击，不触发行点击
        infoView.didClickCheckbox = { [weak self] _ in
            guard let self = self, let dataItem = self.dataItem else {
                return
            }
            
            self.didClickCheckboxHandler?(dataItem)
        }
        gestureRecognizers?.compactMap { $0 as? UITapGestureRecognizer }.forEach { $0.delegate = self }
        
        setupSkeleton()
        
        addSubview(infoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 骨架
    /// 标记骨架块：名称与日期；完成状态与进度条不参与骨架
    private func setupSkeleton() {
        infoView.checkbox.isSkeletonExcluded = true
        infoView.progressView.isSkeletonExcluded = true
        
        infoView.nameLabel.isSkeletonable = true
        infoView.nameLabel.skeletonShape = .capsule
        infoView.nameLabel.skeletonWidthRatio = 0.6
        
        infoView.detailLabel.isSkeletonable = true
        infoView.detailLabel.skeletonShape = .capsule
        infoView.detailLabel.skeletonWidthRatio = 0.35
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        infoView.frame = bounds.inset(by: contentInsets)
    }
    
    // MARK: - 渲染
    /// 更新展示的目标任务。传 nil 时清空内容并展示骨架
    override func update(with dataItem: WSGoalTaskDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem else {
            infoView.name = nil
            infoView.attributedDetail = nil
            infoView.checkbox.isHidden = true
            infoView.isProgressHidden = true
            infoView.setProgress(0.0, animated: false)
            
            setNeedsLayout()
            layoutIfNeeded()
            sk.show(config: skeletonConfig)
            return
        }
        
        sk.hide()
        infoView.checkbox.isHidden = false
        infoView.name = dataItem.title
        infoView.nameLabel.setStrikethrough(dataItem.isCompleted, animated: false)
        
        /// 完成状态样式与任务本身一致，颜色取任务颜色
        infoView.checkType = dataItem.checkType
        infoView.checkbox.setChecked(dataItem.isCompleted, animated: false)
        infoView.checkbox.normalColor = dataItem.color
        infoView.checkbox.checkedColor = dataItem.color
        
        /// 日期区间与目标计划行保持一致
        infoView.attributedDetail = dataItem.intervalText?.attributedString
        
        infoView.isProgressHidden = !dataItem.hasValidProgress
        infoView.setProgress(dataItem.progress, animated: false)
        infoView.progressView.barForeColor = dataItem.color

        setNeedsLayout()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension WSGoalTaskBriefRowView: UIGestureRecognizerDelegate {
    
    /// 点击手势默认作用于整行，完成状态区域内不响应，避免同时触发任务操作
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchedView = touch.view else {
            return true
        }
        
        return !touchedView.isDescendant(of: infoView.checkbox)
    }
}
