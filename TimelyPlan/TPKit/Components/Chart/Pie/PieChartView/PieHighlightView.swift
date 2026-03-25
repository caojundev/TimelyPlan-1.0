//
//  PieHighlightView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/11.
//
import Foundation
import UIKit

/// 饼状图高亮视图 - 覆盖在饼状图上，高亮显示指定的 PieSlice
class PieHighlightView: UIView {
    
    /// 是否需要高亮
    var isHighlighted: Bool = false {
        didSet {
            if isHighlighted {
                self.isHidden = false
                circleView.setNeedsDisplay()
                lineView.setNeedsDisplay()
                labelsView.setNeedsLayout()
            } else {
                self.isHidden = true
            }
        }
    }
    
    /// 高亮的切片数据
    var highlightedSlice: PieSlice? {
        didSet {
            updateVisual()
        }
    }
    
    /// 高亮的切片索引
    var highlightedIndex: Int? {
        didSet {
            updateVisual()
        }
    }
    
    /// 原始视觉数据（用于获取完整信息）
    private var sourceVisual: PieVisual?
    
    /// 要高亮的切片索引
    private var highlightIndex: Int = -1
    
    /// 外环半径
    var outerRadius: CGFloat = 90.0 {
        didSet {
            circleView.outerRadius = outerRadius
            lineView.radius = outerRadius
            labelsView.radius = outerRadius
            setNeedsLayout()
        }
    }
    
    /// 内环半径
    var innerRadius: CGFloat = 65.0 {
        didSet {
            circleView.innerRadius = innerRadius
            setNeedsLayout()
        }
    }
    
    // MARK: - Subviews
    
    /// 高亮饼状图
    private let circleView = HighlightCircleView()
    
    /// 高亮指示线条
    private let lineView = HighlightLineView()
    
    /// 高亮标签
    private let labelsView = HighlightLabelsView()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isHidden = true
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        addSubview(lineView)
        addSubview(labelsView)
        addSubview(circleView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = bounds
        circleView.frame = layoutFrame
        lineView.frame = layoutFrame
        labelsView.frame = layoutFrame
    }
    
    // MARK: - Public Methods
    
    /// 设置源数据并准备高亮
    /// - Parameters:
    ///   - visual: 原始饼状图的视觉数据
    ///   - index: 要高亮的切片索引
    func setup(with visual: PieVisual, highlightIndex index: Int) {
        self.sourceVisual = visual
        self.highlightedIndex = index
        
        if index >= 0 && index < visual.angles.count {
            let slice = visual.slices?[index]
            self.highlightedSlice = slice
        } else {
            self.highlightedSlice = nil
        }
    }
    
    /// 更新高亮状态
    /// - Parameter highlighted: 是否高亮
    func setHighlighted(_ highlighted: Bool) {
        self.isHighlighted = highlighted
    }
    
    // MARK: - Private Methods
    
    private func updateVisual() {
        guard let sourceVisual = sourceVisual,
              let index = highlightedIndex,
              index >= 0 && index < sourceVisual.angles.count else {
            self.highlightIndex = -1
            self.circleView.visual = nil
            self.lineView.visual = nil
            self.labelsView.visual = nil
            return
        }
        
        self.highlightIndex = index
        
        // 设置高亮视图使用原始 visual，但只显示指定索引的切片
        
        circleView.visual = sourceVisual
        circleView.highlightIndex = index
        
        lineView.visual = sourceVisual
        lineView.highlightIndex = index
        
        labelsView.visual = sourceVisual
        labelsView.highlightIndex = index
    }
}

// MARK: - Highlight Circle View
/// 高亮圆环视图 - 只绘制指定索引的切片
class HighlightCircleView: PieCircleView {
    
    var highlightIndex: Int = -1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = Color(light: 0xFFFFFF, dark: 0x000000, alpha: 0.8)
        self.shouldAddAnimation = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let visual = visual, highlightIndex >= 0 else {
            super.draw(rect)
            return
        }
        
        let context = UIGraphicsGetCurrentContext()!
        let circleCenter = bounds.middlePoint
        let angles = visual.angles
        let colors = visual.colors
        
        // 只绘制高亮索引对应的切片
        if highlightIndex < angles.count {
            let angle = angles[highlightIndex]
            draw(angle: angle,
                 withColor: colors[highlightIndex % colors.count],
                 using: context)
        }
        
        /// 绘制内圆
        context.move(to: circleCenter)
        context.addArc(center: circleCenter,
                       radius: innerRadius - pieBorderWidth,
                       startAngle: 0,
                       endAngle: CGFloat.pi * 2,
                       clockwise: false)
        context.closePath()
        context.setFillColor(UIColor.systemBackground.cgColor)
        context.fillPath()
    }
}

// MARK: - Highlight Line View
/// 高亮连接线视图 - 只绘制指定索引的连接线
class HighlightLineView: PieLineView {
    
    var highlightIndex: Int = -1 {
        didSet {
            setupDrawAngles()
            setNeedsDisplay()
        }
    }
    
    override func setupDrawAngles() {
        guard let visual = visual,
              highlightIndex >= 0,
              highlightIndex < visual.angles.count else {
            self.drawAngles = []
            return
        }
        
        let angle = visual.angles[highlightIndex]
        self.drawAngles = [angle]
    }
}

// MARK: - Highlight Labels View
/// 高亮标签视图 - 只显示指定索引的标签
class HighlightLabelsView: PieLabelsView {
    
    var highlightIndex: Int = -1 {
        didSet {
            setupLabelViews()
            setNeedsLayout()
        }
    }
    
    override func setupLabelViews() {
        self.removeViews(labelViews)
        guard let visual = visual, highlightIndex >= 0, highlightIndex < visual.angles.count else {
            self.labelViews = []
            return
        }
        
        let angle = visual.angles[highlightIndex]
        let labelView = PieLabelView(angle: angle)
        addSubview(labelView)
        self.labelViews = [labelView]
    }
}
