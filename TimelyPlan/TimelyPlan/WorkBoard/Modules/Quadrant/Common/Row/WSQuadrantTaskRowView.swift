//
//  WSQuadrantTaskRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation
import UIKit

// MARK: - 任务行视图

/// 四象限任务行视图，各尺寸组件共用。
///
/// 与目标任务详情行展示内容一致：完成状态、名称、日期与进度条；
/// 未设置进度的任务不展示进度条，行高不足时依次省略详情与进度条。
class WSQuadrantTaskRowView: WSRowView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与行边缘的间距。行高较小时由行高直接约束内容
        static let padding = UIEdgeInsets(left: 4.0, right: 4.0)
        
        /// 行按下高亮的圆角
        static let cornerRadius: CGFloat = 6.0
        
        /// 完成状态尺寸
        static let checkboxSize = CGSize(value: 16.0)
        
        /// checkbox 圆角半径
        static let checkboxCornerRadius = 6.0
        
        /// 完成状态与内容的间距
        static let checkboxSpacing: CGFloat = 6.0
        
        /// 名称字体
        static let nameFont = UIFont.boldSystemFont(ofSize: 13.0)
        
        /// 详情字体
        static let detailFont = UIFont.systemFont(ofSize: 11.0)
        
        /// 名称与详情的间距
        static let detailTopMargin: CGFloat = 1.0
        
        /// 详情与进度条的间距
        static let progressTopMargin: CGFloat = 2.0
        
        /// 进度条高度
        static let progressHeight: CGFloat = 2.0
        
        /// 按下时行底色的透明度
        static let highlightedBackgroundColorAlpha: CGFloat = 0.1
    }
    
    /// 完成状态
    private lazy var checkbox: TodoTaskCheckbox = {
        let checkbox = TodoTaskCheckbox()
        checkbox.padding = .zero
        checkbox.hitTestEdgeInsets = UIEdgeInsets(horizontal: -4.0, vertical: -4.0)
        checkbox.addGestureRecognizer(checkboxTapGesture)
        return checkbox
    }()
    
    /// 完成状态的点击手势
    private lazy var checkboxTapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(clickCheckbox(_:)))
    }()
    
    /// 任务名称
    private lazy var nameLabel: TPStrikethroughLabel = {
        let label = TPStrikethroughLabel()
        label.font = Metrics.nameFont
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    /// 任务日期
    private lazy var detailLabel: TPLabel = {
        let label = TPLabel()
        label.font = Metrics.detailFont
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    /// 任务进度
    private lazy var progressView: TPBarProgressView = {
        let view = TPBarProgressView(frame: .zero, style: .horizontal)
        view.cornerRadius = .greatestFiniteMagnitude
        view.isUserInteractionEnabled = false
        return view
    }()
    
    /// 当前展示的任务
    private(set) var dataItem: WSQuadrantTaskItem?
    
    /// 点击任务回调
    var didSelectTaskHandler: ((WSQuadrantTaskItem) -> Void)?
    
    /// 点击完成状态回调
    var didClickCheckboxHandler: ((WSQuadrantTaskItem) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        self.contentCornerRadius = Metrics.cornerRadius
        
        addSubview(checkbox)
        addSubview(nameLabel)
        addSubview(detailLabel)
        addSubview(progressView)
        
        /// 点击完成状态时不触发行点击
        gestureRecognizers?.compactMap { $0 as? UITapGestureRecognizer }.forEach {
            $0.require(toFail: checkboxTapGesture)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = layoutFrame()
        guard contentFrame.width > 0.0, contentFrame.height > 0.0 else {
            return
        }
        
        checkbox.size = Metrics.checkboxSize
        checkbox.cornerRadius = Metrics.checkboxCornerRadius
        checkbox.left = contentFrame.minX
        checkbox.centerY = contentFrame.midY
        
        let contentLeft = checkbox.right + Metrics.checkboxSpacing
        let contentWidth = max(contentFrame.maxX - contentLeft, 0.0)
        let nameHeight = ceil(Metrics.nameFont.lineHeight)
        let detailHeight = ceil(Metrics.detailFont.lineHeight)
        
        /// 进度条优先于详情：行高不足时先省略详情，保证进度可见
        var showsProgress = dataItem?.isProgressSet == true
        var contentHeight = nameHeight
        if showsProgress {
            contentHeight += Metrics.progressTopMargin + Metrics.progressHeight
        }
        if showsProgress && contentHeight > contentFrame.height {
            showsProgress = false
            contentHeight = nameHeight
        }
        
        let showsDetail = dataItem?.detail != nil
            && contentHeight + Metrics.detailTopMargin + detailHeight <= contentFrame.height
        if showsDetail {
            contentHeight += Metrics.detailTopMargin + detailHeight
        }
        
        var top = contentFrame.minY + max((contentFrame.height - contentHeight) / 2.0, 0.0)
        
        nameLabel.frame = CGRect(x: contentLeft, y: top, width: contentWidth, height: nameHeight)
        top += nameHeight
        
        detailLabel.isHidden = !showsDetail
        if showsDetail {
            top += Metrics.detailTopMargin
            detailLabel.frame = CGRect(x: contentLeft, y: top, width: contentWidth, height: detailHeight)
            top += detailHeight
        }
        
        progressView.isHidden = !showsProgress
        if showsProgress {
            top += Metrics.progressTopMargin
            progressView.frame = CGRect(x: contentLeft,
                                        y: top,
                                        width: contentWidth,
                                        height: Metrics.progressHeight)
        }
    }
    
    // MARK: - 渲染
    /// 更新展示的任务。传 nil 时清空内容
    func update(with dataItem: WSQuadrantTaskItem?, color: UIColor) {
        self.dataItem = dataItem
        
        guard let dataItem = dataItem else {
            checkbox.isHidden = true
            nameLabel.text = nil
            nameLabel.setStrikethrough(false, animated: false)
            detailLabel.attributed.text = nil
            progressView.setProgress(0.0, animated: false)
            normalBackColor = .clear
            highlightedBackColor = .clear
            setNeedsLayout()
            return
        }
        
        checkbox.isHidden = false
        checkbox.mode = checkboxMode(for: dataItem.checkType)
        checkbox.normalColor = color
        checkbox.checkedColor = color
        checkbox.setChecked(dataItem.isCompleted, animated: false)
        
        nameLabel.text = dataItem.name
        nameLabel.setStrikethrough(dataItem.isCompleted, animated: false)
        detailLabel.attributed.text = dataItem.detail
        
        progressView.barForeColor = color
        progressView.setProgress(dataItem.progress, animated: false)
        
        normalBackColor = .clear
        highlightedBackColor = color.withAlphaComponent(Metrics.highlightedBackgroundColorAlpha)
        
        setNeedsLayout()
    }
    
    // MARK: - 交互
    override func didSelectRow() {
        guard let dataItem = dataItem else {
            return
        }
        
        didSelectTaskHandler?(dataItem)
    }
    
    @objc private func clickCheckbox(_ gesture: UITapGestureRecognizer) {
        guard let dataItem = dataItem else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        didClickCheckboxHandler?(dataItem)
    }
    
    /// 完成状态样式与任务本身一致
    private func checkboxMode(for checkType: TodoTaskCheckType) -> TodoTaskCheckbox.Mode {
        switch checkType {
        case .normal:
            return .normal
        case .increase:
            return .plus
        case .decrease:
            return .minus
        }
    }
}
