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
/// 复用待办任务的勾选信息视图展示完成状态、名称、详情与进度条；
/// 未设置进度的任务不展示进度条，行高不足时先省略详情。
class WSQuadrantTaskRowView: WSRowView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与行边缘的间距
        static let padding = UIEdgeInsets(left: 4.0, right: 4.0)
        
        /// 行按下高亮的圆角
        static let cornerRadius: CGFloat = 6.0
        
        /// 完成状态尺寸与间距
        static let checkboxSize = CGSize(value: 16.0)
        static let checkboxSpacing: CGFloat = 6.0
        
        /// 名称高度
        static let nameHeight: CGFloat = 18.0
        
        /// 详情高度及与名称的间距
        static let detailHeight: CGFloat = 14.0
        static let detailTopMargin: CGFloat = 2.0
        
        /// 进度条高度及与上方的间距
        static let progressHeight: CGFloat = 2.0
        static let progressTopMargin: CGFloat = 2.0
        
        /// 按下时行底色的透明度
        static let highlightedBackgroundColorAlpha: CGFloat = 0.1
    }
    
    /// 任务勾选信息视图
    private lazy var infoView: TodoTaskCheckInfoView = {
        let view = TodoTaskCheckInfoView()
        /// 名称与详情均只展示一行
        view.nameLabel.numberOfLines = 1
        view.nameLabel.lineBreakMode = .byTruncatingTail
        view.nameLabel.font = .boldSystemFont(ofSize: 13.0)
        
        view.detailLabel.numberOfLines = 1
        view.detailLabel.lineBreakMode = .byTruncatingTail
        view.detailLabel.font = .systemFont(ofSize: 11.0, weight: .medium)
        
        view.nameHeight = Metrics.nameHeight
        view.detailHeight = Metrics.detailHeight
        view.detailTopMargin = Metrics.detailTopMargin
        view.progressHeight = Metrics.progressHeight
        view.progressTopMargin = Metrics.progressTopMargin
        view.leftViewSize = Metrics.checkboxSize
        view.leftViewMargins = UIEdgeInsets(right: Metrics.checkboxSpacing)
        view.checkbox.hitTestEdgeInsets = UIEdgeInsets(horizontal: -4.0, vertical: -4.0)
        view.checkbox.addGestureRecognizer(checkboxTapGesture)
        return view
    }()
    
    /// 完成状态的点击手势
    private lazy var checkboxTapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(clickCheckbox(_:)))
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
        
        addSubview(infoView)
        
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
        
        /// 行高不足时先省略详情，保证进度可见
        let progressHeight = infoView.isProgressHidden ? 0.0 : Metrics.progressTopMargin + Metrics.progressHeight
        let contentHeight = Metrics.nameHeight + progressHeight
        let showsDetail = dataItem?.detail != nil
            && contentHeight + Metrics.detailTopMargin + Metrics.detailHeight <= contentFrame.height
        
        infoView.attributedDetail = showsDetail ? dataItem?.detail : nil
        infoView.detailHeight = showsDetail ? Metrics.detailHeight : 0.0
        infoView.frame = contentFrame
    }
    
    // MARK: - 渲染
    /// 更新展示的任务。传 nil 时清空内容
    func update(with dataItem: WSQuadrantTaskItem?, color: UIColor) {
        self.dataItem = dataItem
        
        guard let dataItem = dataItem else {
            infoView.isHidden = true
            infoView.name = nil
            infoView.attributedDetail = nil
            normalBackColor = .clear
            highlightedBackColor = .clear
            setNeedsLayout()
            return
        }
        
        infoView.isHidden = false
        infoView.name = dataItem.name
        infoView.checkType = dataItem.checkType
        infoView.isCompleted = dataItem.isCompleted
        infoView.setProgress(dataItem.progress, animated: false)
        infoView.isProgressHidden = !dataItem.isProgressSet
        infoView.setNeedsLayout()
        
        /// 完成状态与进度使用象限颜色
        infoView.checkbox.normalColor = color
        infoView.checkbox.checkedColor = color
        infoView.progressView.barForeColor = color
        
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
}
