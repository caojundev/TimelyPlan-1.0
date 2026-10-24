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
/// 收拢各行共有的部分：点击与高亮、图标与剩余时间视图、字号换算、骨架切换与内容渲染模板；
/// 子类只需搭建并布局信息区（名称、日期等），再按需调整尺寸参数。
class WSCountdownEventRowBaseView: UIView {
    
    // MARK: - 事项
    /// 当前展示的事项
    private(set) var dataItem: WSCountdownDataItem?
    
    /// 点击回调。空白行（没有事项）同样回调，此时参数为 nil，由组件决定如何响应
    var didSelectHandler: ((WSCountdownDataItem?) -> Void)?
    
    // MARK: - 外观
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
    
    /// 骨架配置。行自带底色时可由外部覆盖，避免骨架块与行底色对比过低
    var skeletonConfig: SkeletonConfig = Skeleton.config
    
    // MARK: - 尺寸参数。均按行高换算，子类按需调整
    /// 图标边长占行高的比例及范围
    var iconHeightRatio: CGFloat = 0.5
    var iconMinSide: CGFloat = 22.0
    var iconMaxSide: CGFloat = 40.0
    
    /// emoji 字号占图标边长的比例
    var iconFontRatio: CGFloat = 0.52
    
    /// 数值字号占行高的比例及范围
    var valueFontRatio: CGFloat = 0.3
    var valueMinFontSize: CGFloat = 13.0
    var valueMaxFontSize: CGFloat = 26.0
    
    /// 单位 /「今天」字号占数值字号的比例
    var unitFontRatio: CGFloat = 0.45
    var todayFontRatio: CGFloat = 0.65
    
    // MARK: - 子视图
    /// 图标视图
    let iconView = TPIconView()
    
    /// 剩余时间视图
    let valueView = CountdownTimeValueView()
    
    // MARK: - 状态
    /// 当前是否处于按下高亮状态
    private(set) var isRowHighlighted: Bool = false
    
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
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 统一搭建图标与剩余时间视图
    private func setupSubviews() {
        /// 组件为浅色背景，剩余时间使用常规文本色，单位弱化，不绘制光晕
        valueView.textAlignment = .left
        valueView.textColor = .label
        valueView.unitColor = .secondaryLabel
        valueView.glowColor = .clear
        
        /// 骨架标记：直接标记真实子视图，由 Skeleton 统一绘制
        iconView.isSkeletonable = true
        iconView.skeletonShape = .circle
        
        valueView.isSkeletonable = true
        valueView.skeletonShape = .capsule
        
        addSubview(iconView)
        addSubview(valueView)
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
    /// 渲染信息区：名称、日期等。图标与剩余时间由基类统一渲染
    func reloadInfo(with dataItem: WSCountdownDataItem) {
        
    }
    
    /// 清空信息区，保留视图结构供骨架绘制
    func clearInfo() {
        
    }
    
    /// 更新字号。尺寸变化时由基类调用，子类覆写后需调用 `super`
    func updateFonts(in layoutFrame: CGRect) {
        guard layoutFrame.height > 0.0 else {
            return
        }
        
        iconView.font = .systemFont(ofSize: floor(iconSide(in: layoutFrame) * iconFontRatio))
        
        let valueFontSize = min(max(floor(layoutFrame.height * valueFontRatio), valueMinFontSize),
                                valueMaxFontSize)
        valueView.valueFont = .monospacedDigitSystemFont(ofSize: valueFontSize, weight: .heavy)
        valueView.unitFont = .systemFont(ofSize: max(floor(valueFontSize * unitFontRatio), 10.0), weight: .medium)
        valueView.todayFont = .systemFont(ofSize: max(floor(valueFontSize * todayFontRatio), 11.0), weight: .bold)
    }
    
    /// 布局子视图。子类只需摆放信息区，图标与剩余时间可用下方方法统一摆放
    /// - Parameter layoutFrame: 已去掉 `padding` 的可用区域
    func layoutContent(in layoutFrame: CGRect) {
        
    }
    
    // MARK: - 布局辅助
    /// 图标边长
    func iconSide(in layoutFrame: CGRect) -> CGFloat {
        let side = floor(layoutFrame.height * iconHeightRatio)
        return min(max(side, iconMinSide), iconMaxSide)
    }
    
    /// 剩余时间行高
    var valueLineHeight: CGFloat {
        return ceil(valueView.valueFont.lineHeight)
    }
    
    /// 图标靠左、垂直居中排列
    /// - Returns: 图标边长
    @discardableResult
    func layoutIconAtLeadingCenter(in layoutFrame: CGRect) -> CGFloat {
        let side = iconSide(in: layoutFrame)
        iconView.size = CGSize(width: side, height: side)
        iconView.left = layoutFrame.minX
        iconView.centerY = layoutFrame.midY
        iconView.cornerRadius = side / 2.0
        return side
    }
    
    /// 图标靠左上排列
    /// - Returns: 图标边长
    @discardableResult
    func layoutIconAtLeadingTop(in layoutFrame: CGRect) -> CGFloat {
        let side = iconSide(in: layoutFrame)
        iconView.size = CGSize(width: side, height: side)
        iconView.left = layoutFrame.minX
        iconView.top = layoutFrame.minY
        iconView.cornerRadius = side / 2.0
        return side
    }
    
    /// 剩余时间贴着底部、占满宽度排列
    func layoutValueAtBottom(in layoutFrame: CGRect) {
        let height = valueLineHeight
        valueView.frame = CGRect(x: layoutFrame.minX,
                                 y: layoutFrame.maxY - height,
                                 width: layoutFrame.width,
                                 height: height)
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        isLayoutSizeChanged = laidOutSize != layoutFrame.size
        laidOutSize = layoutFrame.size
        
        if isLayoutSizeChanged {
            updateFonts(in: layoutFrame)
        }
        
        layoutContent(in: layoutFrame)
        
        /// 骨架已展示时按最新布局重算，覆盖首次在零尺寸下创建的情况
        if isLayoutSizeChanged, sk.isShowing {
            sk.reload()
        }
    }
    
    // MARK: - 渲染模板
    /// 渲染图标、剩余时间与信息区
    func reloadContent(with dataItem: WSCountdownDataItem) {
        iconView.icon = TPIcon(text: dataItem.emoji)
        iconView.backColor = dataItem.color
        valueView.result = dataItem.timeResult
        reloadInfo(with: dataItem)
    }
    
    /// 清空内容，保留视图结构供骨架绘制
    func clearContent() {
        iconView.icon = nil
        iconView.backColor = .clear
        valueView.result = nil
        clearInfo()
    }
    
    // MARK: - 点击
    /// 点击行，回调当前行展示的事项；空白行同样回调，交由组件统一响应
    @objc private func clickRow(_ gesture: UITapGestureRecognizer) {
        TPImpactFeedback.impactWithSoftStyle()
        didSelectHandler?(dataItem)
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
