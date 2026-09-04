//
//  GoalTaskInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/3.
//

import Foundation
import UIKit

/// 目标任务信息视图基类（名称 + 详情 + 进度条 + 左右配件视图）
class GoalTaskBaseInfoView: UIView {
    
    /// 任务名称
    var name: String? {
        get {
            return nameLabel.text
        }
        
        set {
            nameLabel.text = newValue
            setNeedsLayout()
        }
    }
    
    /// 详情文本
    var detailText: String? {
        get {
            return detailLabel.text
        }
        
        set {
            detailLabel.text = newValue
            setNeedsLayout()
        }
    }
    
    var nameHeight: CGFloat = 30.0 {
        didSet {
            if nameHeight != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    var detailTopMargin: CGFloat = 5.0 {
        didSet {
            if detailTopMargin != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    var detailHeight: CGFloat = 20.0 {
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
    var progressTopMargin: CGFloat = 4.0 {
        didSet {
            if progressTopMargin != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    var progressHeight: CGFloat = 6.0 {
        didSet {
            if progressHeight != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    var isProgressHidden: Bool = false {
        didSet {
            if isProgressHidden != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    private(set) lazy var progressView: TPBarProgressView = {
        let view = TPBarProgressView(frame: .zero, style: .horizontal)
        view.cornerRadius = .greatestFiniteMagnitude
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutLeftView()
        layoutRightView()
        layoutContents()
    }
    
    /// 当前可用的标签布局区域
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
        progressView.top = detailLabel.bottom + progressTopMargin
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
    
    // MARK: - Public Methods
    /// 设置进度
    func setProgress(_ progress: CGFloat,
                     animated: Bool = false,
                     completion: (() -> Void)? = nil) {
        progressView.setProgress(progress, animated: animated, completion: completion)
    }
    
    /// 更新内容
    func updateContent(with layout: GoalTaskInfoLayout, animated: Bool) {
        updateLayout(with: layout)
        
        let task = layout.task
        
        name = task.name
        detailText = layout.detailText
        
        setProgress(layout.progress, animated: animated)
        setNeedsLayout()
    }
    
    /// 更新布局参数
    func updateLayout(with layout: GoalTaskInfoLayout) {
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

/// 目标任务复选信息视图
class GoalTaskCheckInfoView: GoalTaskBaseInfoView {
    
    /// 检查类型
    var checkType: TodoTaskCheckType = .normal {
        didSet {
            if checkType != oldValue {
                updateCheckbox()
            }
        }
    }
    
    /// 点击复选框
    var didClickCheckbox: ((TodoTaskCheckbox) -> Void)?
    
    /// 复选框尺寸
    let checkboxSize = CGSize(width: 20.0, height: 20.0)
    
    /// 复选框外间距
    let checkboxMargins = UIEdgeInsets(right: 10.0)
    
    /// 复选框
    private(set) lazy var checkbox: TodoTaskCheckbox = {
        let checkbox = TodoTaskCheckbox()
        checkbox.hitTestEdgeInsets = UIEdgeInsets(horizontal: -20.0, vertical: -20.0)
        checkbox.padding = .zero
        checkbox.addTarget(self,
                           action: #selector(clickCheckbox(_:)),
                           for: .touchUpInside)
        return checkbox
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        self.leftView = checkbox
        self.leftViewSize = checkboxSize
        self.leftViewMargins = checkboxMargins
    }
    
    override func layoutLeftView() {
        super.layoutLeftView()
        let layoutFrame = layoutFrame()
        checkbox.centerY = layoutFrame.midY
    }
    
    /// 点击复选框
    @objc func clickCheckbox(_ button: UIButton) {
        didClickCheckbox?(checkbox)
    }
    
    func updateCheckbox() {
        switch checkType {
        case .normal:
            checkbox.mode = .normal
        case .increase:
            checkbox.mode = .plus
        case .decrease:
            checkbox.mode = .minus
        }
    }
    
    override func updateContent(with layout: GoalTaskInfoLayout, animated: Bool) {
        super.updateContent(with: layout, animated: animated)
        self.checkType = layout.task.checkType
    }
}
