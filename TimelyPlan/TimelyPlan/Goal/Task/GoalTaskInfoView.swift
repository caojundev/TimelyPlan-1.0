//
//  GoalTaskInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/3.
//

import Foundation
import UIKit

/// 目标任务信息视图（名称 + 详情 + 进度条）
class GoalTaskInfoView: UIView {
    
    /// 名称高度
    var nameHeight: CGFloat = 30.0 {
        didSet {
            if nameHeight != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 详情顶部间距
    var detailTopMargin: CGFloat = 5.0 {
        didSet {
            if detailTopMargin != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 详情高度
    var detailHeight: CGFloat = 20.0 {
        didSet {
            if detailHeight != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 进度条顶部间距
    var progressTopMargin: CGFloat = 4.0 {
        didSet {
            if progressTopMargin != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 进度条高度
    var progressHeight: CGFloat = 2.0 {
        didSet {
            if progressHeight != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 进度条是否隐藏
    var isProgressHidden: Bool = false {
        didSet {
            if isProgressHidden != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 名称标签
    private(set) lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15.0)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    /// 详情标签
    private(set) lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11.0)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    /// 进度视图
    private(set) lazy var progressView: TPBarProgressView = {
        let view = TPBarProgressView(frame: .zero, style: .horizontal)
        view.isUserInteractionEnabled = false
        view.barForeColor = .primary
        view.isHidden = isProgressHidden
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func setupSubviews() {
        addSubview(nameLabel)
        addSubview(detailLabel)
        addSubview(progressView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutContents()
    }
    
    /// 布局内容
    private func layoutContents() {
        let layoutFrame = bounds
        
        var contentHeight = nameHeight
        if detailHeight > 0 {
            contentHeight += detailTopMargin + detailHeight
        }
        
        if !isProgressHidden {
            contentHeight += progressTopMargin + progressHeight
        }
        
        let topMargin = max((layoutFrame.height - contentHeight) / 2.0, 0.0)
        
        nameLabel.width = layoutFrame.width
        nameLabel.height = nameHeight
        nameLabel.left = layoutFrame.minX
        nameLabel.top = layoutFrame.minY + topMargin
        
        detailLabel.width = layoutFrame.width
        detailLabel.height = detailHeight
        detailLabel.left = layoutFrame.minX
        detailLabel.top = nameLabel.bottom + detailTopMargin
        
        progressView.isHidden = isProgressHidden
        progressView.width = layoutFrame.width
        progressView.height = progressHeight
        progressView.left = layoutFrame.minX
        progressView.top = detailLabel.bottom + progressTopMargin
    }
    
    // MARK: - Public Methods
    /// 设置进度
    func setProgress(_ progress: CGFloat, animated: Bool = false) {
        progressView.setProgress(progress, animated: animated)
    }
    
    /// 更新内容
    func updateContent(with layout: GoalTaskInfoLayout, animated: Bool) {
        updateLayout(with: layout)
        nameLabel.text = layout.task.name
        detailLabel.text = layout.detailText
        setProgress(layout.progress, animated: animated)
        setNeedsLayout()
    }
    
    /// 更新布局参数
    func updateLayout(with layout: GoalTaskInfoLayout) {
        nameHeight = layout.nameHeight
        detailHeight = layout.detailHeight
        isProgressHidden = layout.isProgressHidden
        
        let config = layout.config
        nameLabel.font = config.nameFont
        detailTopMargin = config.detailTopMargin
        detailLabel.font = config.detailFont
        progressTopMargin = config.progressTopMargin
        progressHeight = config.progressHeight
    }
}
