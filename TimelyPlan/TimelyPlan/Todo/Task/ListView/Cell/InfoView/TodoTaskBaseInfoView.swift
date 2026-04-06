//
//  TodoTaskBaseInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/12.
//

import Foundation
import UIKit

class TodoTaskBaseInfoView: UIView {
    
    /// 任务名称
    var name: String? {
        didSet {
            if name != oldValue {
                nameLabel.text = name
                setNeedsLayout()
            }
        }
    }
    
    /// 详情富文本信息
    var attributedDetail: ASAttributedString? {
        didSet {
            if attributedDetail != oldValue {
                detailLabel.attributed.text = attributedDetail
                setNeedsLayout()
            }
        }
    }
    
    /// 是否已完成
    var isCompleted: Bool = false {
        didSet {
            if isCompleted != oldValue {
                setCompleted(isCompleted, animated: false)
            }
        }
    }
    
    /// 优先级
    var priority: TodoTaskPriority = .none {
        didSet {
            if priority != oldValue {
                priorityDidChange()
            }
        }
    }
    
    /// 检查类型
    var checkType: TodoTaskCheckType = .normal {
        didSet {
            if checkType != oldValue {
                checkTypeDidChange()
            }
        }
    }
    
    var nameHeight = 30.0 {
        didSet {
            if nameHeight != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    var detailTopMargin = 5.0 {
        didSet {
            if detailTopMargin != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    var detailHeight = 20.0 {
        didSet {
            if detailHeight != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 左侧视图
    var leftView: UIView? {
        didSet {
            if leftView !== oldValue {
                oldValue?.removeFromSuperview()
            }
            
            if let leftView = leftView {
                addSubview(leftView)
            }
            
            setNeedsLayout()
        }
    }
 
    /// 左侧视图尺寸
    var leftViewSize: CGSize = .zero {
        didSet {
            if leftViewSize != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 左侧视图外间距
    var leftViewMargins: UIEdgeInsets = .zero {
        didSet {
            if leftViewMargins != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 右侧视图
    var rightView: UIView? {
        didSet {
            if rightView !== oldValue {
                oldValue?.removeFromSuperview()
            }
            
            if let rightView = rightView {
                addSubview(rightView)
            }
            
            setNeedsLayout()
        }
    }
 
    /// 右侧视图尺寸
    var rightViewSize: CGSize = .zero {
        didSet {
            if rightViewSize != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 右侧视图外间距
    var rightViewMargins: UIEdgeInsets = .zero {
        didSet {
            if rightViewMargins != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 名称标签
    private(set) lazy var nameLabel: TPStrikethroughLabel = {
        let label = TPStrikethroughLabel()
        label.font = UIFont.boldSystemFont(ofSize: 15.0)
        label.textAlignment = .left
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    /// 详细文本标签
    private(set) lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    /// 进度视图
    var progressTopMargin = 4.0
    var progressHeight = 2.0
    var isProgressHidden = false
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
        addSubview(progressView)
        addSubview(nameLabel)
        addSubview(detailLabel)
        priorityDidChange()
        checkTypeDidChange()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutLeftView()
        layoutRightView()
        layoutContents()
    }
    
    /// 当前可用的布局区域
    func labelLayoutFrame() -> CGRect {
        let layoutFrame = layoutFrame()
        let insets = UIEdgeInsets(left: leftViewSize.width + leftViewMargins.horizontalLength,
                                  right: rightViewSize.width + rightViewMargins.horizontalLength)
        return layoutFrame.inset(by: insets)
    }
    /// 布局标签
    func layoutContents() {
        let layoutFrame = labelLayoutFrame()
        var contentHeight = nameHeight
        if detailHeight > 0 {
            contentHeight += detailTopMargin + detailHeight
        }
        
        if !isProgressHidden {
            contentHeight += progressTopMargin + progressHeight
        }
        
        let topMargin = (layoutFrame.height - contentHeight) / 2.0
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
        progressView.bottom = layoutFrame.maxY
    }
    
    /// 布局左视图
    func layoutLeftView() {
        guard let leftView = leftView else {
            return
        }

        let layoutFrame = layoutFrame()
        leftView.size = leftViewSize
        leftView.left = layoutFrame.minX + leftViewMargins.left
        leftView.centerY = layoutFrame.midY
    }
    
    /// 布局右视图
    func layoutRightView() {
        guard let rightView = rightView else {
            return
        }
        
        let layoutFrame = layoutFrame()
        rightView.size = rightViewSize
        rightView.right = layoutFrame.maxX - rightViewMargins.right
        rightView.centerY = layoutFrame.midY
    }
    
    // MARK: -
    func priorityDidChange() {
        
    }
    
    func checkTypeDidChange() {
        
    }
    
    // MARK: - Public Methods
    func setCompleted(_ isCompleted: Bool, animated: Bool = false) {
        guard nameLabel.isStrikethrough != isCompleted else {
            return
        }
        
        nameLabel.setStrikethrough(isCompleted, animated: animated)
        self.setNeedsLayout()
    }
    
    func setProgress(_ progress: CGFloat, animated: Bool) {
        progressView.setProgress(progress, animated: animated)
    }
    
    func updateContent(with layout: TodoTaskInfoLayout, animated: Bool) {
        updateLayout(with: layout)
        if layout.showDetail {
            attributedDetail = layout.detailProvider.attributedInfo()
        } else {
            attributedDetail = nil
        }
        
        let task = layout.task
        checkType = task.checkType
        priority = task.priority
        name = task.name
        setProgress(task.completionRate, animated: animated)
        setCompleted(task.isCompleted, animated: animated)
        setNeedsLayout()
    }
    
    func updateLayout(with layout: TodoTaskInfoLayout) {
        nameHeight = layout.nameHeight
        detailHeight = layout.detailHeight
        isProgressHidden = layout.isProgressHidden
        
        let config = layout.config
        padding = config.padding
        nameLabel.font = config.nameFont
        detailTopMargin = config.detailTopMargin
        detailLabel.font = config.detailFont
        progressTopMargin = config.progressTopMargin
        progressHeight = config.progressHeight
    }
}
