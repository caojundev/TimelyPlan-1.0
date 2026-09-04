//
//  GoalTaskListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/2.
//

import Foundation
import UIKit

protocol GoalTaskPageCheckCellDelegate: AnyObject {
    
    /// 点击复选框
    func goalTaskPageCheckCellDidClickCheckbox(_ cell: GoalTaskPageCheckCell)
    
    /// 点击更多
    func goalTaskPageCheckCellDidClickMore(_ cell: GoalTaskPageCheckCell)
}

/// 目标任务页面单元格基类
class GoalTaskPageBaseCell: UICollectionViewCell, Checkable {
    
    weak var delegate: AnyObject?
    
    /// 任务布局对象
    var layout: GoalTaskInfoLayout?
    
    /// 目标任务
    var goalTask: GoalTask? {
        return layout?.task
    }
    
    /// 信息视图
    var infoView: GoalTaskBaseInfoView!
    
    /// 圆角半径
    var cornerRadius: CGFloat = 12.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundView = UIView()
        self.backgroundView?.clipsToBounds = true
        self.backgroundView?.backgroundColor = .secondarySystemGroupedBackground
        
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.clipsToBounds = true
        self.selectedBackgroundView?.backgroundColor = .tertiarySystemGroupedBackground
        
        self.setupContentSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = bounds
        backgroundView?.layer.cornerRadius = cornerRadius
        selectedBackgroundView?.layer.cornerRadius = cornerRadius
        self.tp_setBorderShadow(color: Color(0x666666, 0.1),
                                offset: .zero,
                                radius: 2.0,
                                roundCorners: .allCorners,
                                cornerRadius: cornerRadius)
    }
    
    func setupContentSubviews() {
        contentView.addSubview(infoView)
    }
    
    /// 重新加载数据
    func reloadData(animated: Bool) {
        guard let layout = layout else {
            return
        }
        
        infoView.updateContent(with: layout, animated: animated)
        setNeedsLayout()
    }
    
    // MARK: - Progress
    func setProgress(_ progress: CGFloat,
                     animated: Bool = false,
                     completion: (() -> Void)? = nil) {
        infoView.setProgress(progress, animated: animated, completion: completion)
    }
    
    // MARK: - Checkable
    private var _isChecked: Bool = false
    var isChecked: Bool {
        get { return _isChecked }
        set { setChecked(newValue, animated: false) }
    }
    
    func setChecked(_ checked: Bool, animated: Bool) {
        _isChecked = checked
    }
}

/// 目标任务复选单元格（左侧复选框 + 右侧更多按钮）
class GoalTaskPageCheckCell: GoalTaskPageBaseCell, FocusAnimatable {
    
    /// 复选框
    var checkbox: TodoTaskCheckbox {
        return checkInfoView.checkbox
    }
    
    /// 复选信息视图
    private lazy var checkInfoView: GoalTaskCheckInfoView = {
        let view = GoalTaskCheckInfoView()
        view.didClickCheckbox = { [weak self] _ in
            self?.clickCheckbox()
        }
        
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
        self.infoView = checkInfoView
        super.setupContentSubviews()
        
        /// 更多按钮作为右侧配件视图
        checkInfoView.rightView = moreButton
    }
    
    override func reloadData(animated: Bool) {
        super.reloadData(animated: animated)
        if let layout = layout {
            let config = layout.config
            checkInfoView.leftViewSize = config.checkboxConfig.size
            checkInfoView.leftViewMargins = config.checkboxMargins
            checkInfoView.rightViewSize = config.moreButtonSize
            checkInfoView.rightViewMargins = config.moreButtonMargins
            checkInfoView.checkbox.config = config.checkboxConfig
            checkInfoView.setNeedsLayout()
        }
        
        setNeedsLayout()
    }
    
    /// 点击复选框
    func clickCheckbox() {
        if let delegate = delegate as? GoalTaskPageCheckCellDelegate {
            delegate.goalTaskPageCheckCellDidClickCheckbox(self)
        }
    }
    
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        if let delegate = delegate as? GoalTaskPageCheckCellDelegate {
            delegate.goalTaskPageCheckCellDidClickMore(self)
        }
    }
    
    // MARK: - FocusAnimatable
    var focusCornerRadius: CGFloat {
        self.cornerRadius
    }
}
