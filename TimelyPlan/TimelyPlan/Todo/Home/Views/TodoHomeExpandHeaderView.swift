//
//  TodoHomeExpandHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/7.
//

import Foundation
import UIKit

protocol TodoHomeExpandHeaderViewDelegate: AnyObject {
    
    /// 点击添加
    func todoHomeExpandHeaderViewDidClickAdd(_ headerView: TodoHomeExpandHeaderView)
    
    /// 展开状态改变
    func todoHomeExpandHeaderView(_ headerView: TodoHomeExpandHeaderView, didToggleExpand isExpanded: Bool)
}


class TodoHomeExpandHeaderView: TPDefaultInfoTableHeaderFooterView {
    
    /// 是否已展开
    var isExpanded: Bool {
        get {
            return expandButton.isExpanded
        }
        
        set {
            setExpanded(newValue, animated: false)
        }
    }
    
    var imageContent: TPImageContent? {
        didSet {
            imageInfoTextValueView.imageContent = imageContent
        }
    }
    
    var imageConfig: TPImageAccessoryConfig {
        get {
            return imageInfoTextValueView.imageConfig
        }
        
        set {
            imageInfoTextValueView.imageConfig = newValue
            setNeedsLayout()
        }
    }
    
    /// 展开按钮
    private(set) lazy var expandButton: TPChevronExpandButton = {
        let button = TPChevronExpandButton()
        button.padding = .zero
        button.image = resGetImage("todo_home_expand_18")
        button.imageConfig.color = .systemGray3
        button.addTarget(self,
                         action: #selector(clickExpand(_:)),
                         for: .touchUpInside)
        return button
    }()

    /// 添加按钮
    lazy var addButton: TPDefaultButton = {
        let button = TPDefaultButton.addButton()
        button.addTarget(self, action: #selector(clickAdd(_:)), for: .touchUpInside)
        return button
    }()

    var imageInfoTextValueView: TPImageInfoTextValueView {
        return infoView as! TPImageInfoTextValueView
    }
    
    /// 点击手势
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(handleTap(_:)))
        return gesture
    }()
    
    override func setupInfoView() {
        infoView = TPImageInfoTextValueView()
        infoView.addGestureRecognizer(tapGesture)
        infoView.titleConfig.font = .boldSystemFont(ofSize: 15.0)
        imageConfig.shouldRenderImageWithColor = false
        imageConfig.margins = UIEdgeInsets(right: 6.0)
        infoView.rightAccessoryView = addButton
        infoView.rightAccessorySize = .size(8)
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentPadding = UIEdgeInsets(left: 16.0, right: 16.0)
        rightView = expandButton
        rightViewSize = CGSize(width: 18.0, height: 18.0)
        setExpanded(isExpanded, animated: false)
    }
    
    private func toggleExpand() {
        setExpanded(!isExpanded, animated: true)
        
        /// 通知代理对象
        if let delegate = delegate as? TodoHomeExpandHeaderViewDelegate {
            delegate.todoHomeExpandHeaderView(self, didToggleExpand: isExpanded)
        }
    }
    
    // MARK: - Event Response
    /// 点击展开或收起按钮
    @objc private func clickExpand(_ button: UIButton) {
        toggleExpand()
    }
    
    @objc private func clickAdd(_ button: UIButton) {
        if let delegate = delegate as? TodoHomeExpandHeaderViewDelegate {
            delegate.todoHomeExpandHeaderViewDidClickAdd(self)
        }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        TPImpactFeedback.impactWithSoftStyle()
        toggleExpand()
    }
    
    // MARK: - Public Methods
    /// 动画更新展开状态
    func setExpanded(_ isExpanded: Bool, animated: Bool) {
        guard expandButton.isExpanded != isExpanded else {
            return
        }
        
        expandButton.setExpanded(isExpanded, animated: animated)
        didChangeExpandedStatus()
        if animated {
            animateLayout(withDuration: 0.25)
        } else {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    func didChangeExpandedStatus() {
        
    }
}
