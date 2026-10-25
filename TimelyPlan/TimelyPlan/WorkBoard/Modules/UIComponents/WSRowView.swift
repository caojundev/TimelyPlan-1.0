//
//  WSRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation
import UIKit

// MARK: - 行视图基类

/// 可点击行视图基类。
///
/// 收拢行共有的外观与交互：常规 / 按下底色、圆角裁剪、骨架配置，
/// 以及点击时的反馈与高亮动画。子类只需搭建并布局内容，
/// 需要把行内数据一并回调时覆写 `didSelectRow()`。
class WSRowView: UIView {
    
    // MARK: - 外观
    /// 常规背景色
    var normalBackColor: UIColor = .clear {
        didSet {
            updateBackColor()
        }
    }
    
    /// 按下时的背景色
    var highlightedBackColor: UIColor = Color(0x888888, 0.1)
    
    /// 是否允许按下高亮。为 false 时点击不改变背景色，点击回调仍会触发
    var isHighlightEnabled: Bool = true {
        didSet {
            updateHighlightedState(false)
        }
    }
    
    /// 圆角半径。大于 0 时内容随圆角裁剪
    var contentCornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = contentCornerRadius
            clipsToBounds = contentCornerRadius > 0.0
        }
    }
    
    /// 骨架配置。行自带底色时可由外部覆盖，避免骨架块与行底色对比过低
    var skeletonConfig: SkeletonConfig = Skeleton.config
    
    // MARK: - 点击
    /// 点击回调
    var didSelectHandler: (() -> Void)?
    
    /// 当前是否处于按下高亮状态
    private(set) var isRowHighlighted: Bool = false
    
    /// 点击手势
    private lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(clickRow(_:)))
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = normalBackColor
        
        /// 点击行触发回调
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 子类实现
    /// 点击行。默认触发 `didSelectHandler`；
    /// 需要把行内数据一并回调时覆写，覆写后无需调用 `super`
    func didSelectRow() {
        didSelectHandler?()
    }
    
    // MARK: - 点击
    @objc private func clickRow(_ gesture: UITapGestureRecognizer) {
        TPImpactFeedback.impactWithSoftStyle()
        didSelectRow()
    }
    
    // MARK: - 高亮
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        updateHighlightedState(true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        updateHighlightedState(false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        updateHighlightedState(false)
    }
    
    /// 设置高亮背景，提示行可点击。不允许高亮时始终保持常规背景色
    private func updateHighlightedState(_ isHighlighted: Bool) {
        let shouldHighlight = isHighlighted && isHighlightEnabled
        guard isRowHighlighted != shouldHighlight else {
            return
        }
        
        isRowHighlighted = shouldHighlight
        UIView.animate(withDuration: 0.15) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.backgroundColor = shouldHighlight ? self.highlightedBackColor : self.normalBackColor
        }
    }
    
    /// 刷新背景色：未按下时使用常规背景色
    private func updateBackColor() {
        backgroundColor = isRowHighlighted ? highlightedBackColor : normalBackColor
    }
}
