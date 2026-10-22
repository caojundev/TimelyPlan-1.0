//
//  WSCountdownEventRowBaseView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 行视图基类

/// 倒数日事项行视图基类。
///
/// 统一处理行内与排版无关的通用能力：点击手势与回调、按下高亮、事项更新与骨架切换；
/// 子类只负责子视图搭建、内容渲染与具体布局，便于按组件尺寸组合出不同复杂度的行。
class WSCountdownEventRowBaseView: UIView {
    
    /// 当前展示的事项
    private(set) var dataItem: WSCountdownDataItem?
    
    /// 点击回调，参数为当前行展示的事项
    var didSelectHandler: ((WSCountdownDataItem) -> Void)?
    
    /// 常规背景色
    var normalBackColor: UIColor = .clear {
        didSet {
            updateBackColor()
        }
    }
    
    /// 按下时的背景色
    var highlightedBackColor: UIColor = Color(0x888888, 0.1)
    
    /// 圆角半径。大于 0 时内容随圆角裁剪
    var contentCornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = contentCornerRadius
            clipsToBounds = contentCornerRadius > 0.0
        }
    }
    
    /// 当前是否处于按下高亮状态
    private(set) var isRowHighlighted: Bool = false
    
    /// 骨架配置。行自带底色时可由外部覆盖，避免骨架块与行底色对比过低
    var skeletonConfig: SkeletonConfig = Skeleton.config
    
    /// 本次布局的可用区域尺寸是否发生变化
    private(set) var isLayoutSizeChanged: Bool = false
    
    /// 上一次布局的可用区域尺寸
    private var laidOutSize: CGSize = .zero
    
    /// 点击手势
    private lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(clickRow(_:)))
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = normalBackColor
        
        /// 点击行展示该行的倒数日事项
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 更新
    /// 更新展示的事项。传 nil 时清空内容并展示骨架
    func update(with dataItem: WSCountdownDataItem?) {
        self.dataItem = dataItem
        
        guard let dataItem = dataItem else {
            clearContent()
            
            /// 清空内容后再展示骨架，避免旧内容短暂透出；
            /// 子视图不能隐藏，否则 Skeleton 遍历时会直接跳过
            setNeedsLayout()
            sk.show(config: skeletonConfig)
            return
        }
        
        sk.hide()
        reloadContent(with: dataItem)
        setNeedsLayout()
    }
    
    // MARK: - 子类实现
    /// 渲染事项内容：写入图标、文本与数值。有数据时由 `update(with:)` 调用
    func reloadContent(with dataItem: WSCountdownDataItem) {
        
    }
    
    /// 清空内容，保留视图结构供骨架绘制。无数据时由 `update(with:)` 调用
    func clearContent() {
        
    }
    
    /// 布局子视图
    /// - Parameter layoutFrame: 已去掉 `padding` 的可用区域
    func layoutContent(in layoutFrame: CGRect) {
        
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        isLayoutSizeChanged = laidOutSize != layoutFrame.size
        laidOutSize = layoutFrame.size
        
        layoutContent(in: layoutFrame)
        
        /// 骨架已展示时按最新布局重算，覆盖首次在零尺寸下创建的情况
        if isLayoutSizeChanged, sk.isShowing {
            sk.reload()
        }
    }
    
    // MARK: - 点击
    /// 点击行，回调当前行展示的事项
    @objc private func clickRow(_ gesture: UITapGestureRecognizer) {
        guard let dataItem = dataItem else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        didSelectHandler?(dataItem)
    }
    
    // MARK: - 高亮
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard dataItem != nil else {
            return
        }
        
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
    
    /// 设置高亮背景，提示行可点击
    private func updateHighlightedState(_ isHighlighted: Bool) {
        guard isRowHighlighted != isHighlighted else {
            return
        }
        
        isRowHighlighted = isHighlighted
        UIView.animate(withDuration: 0.15) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.backgroundColor = isHighlighted ? self.highlightedBackColor : self.normalBackColor
        }
    }
    
    /// 刷新背景色：未按下时使用常规背景色
    private func updateBackColor() {
        backgroundColor = isRowHighlighted ? highlightedBackColor : normalBackColor
    }
}
