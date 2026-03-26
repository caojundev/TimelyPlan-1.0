//
//  PieChartView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/11.
//

import UIKit

class PieChartView: UIView {
    
    var visual:PieVisual! {
        didSet {
            setHighlight(false)
            circleView.visual = visual
            lineView.visual = visual
            labelsView.visual = visual
        }
    }
    
    var angles: [PieSliceAngle] {
        visual.angles
    }
    
    var colors:[UIColor] {
        visual.colors
    }
    
    /// 外环半径
    var outerRadius: CGFloat = 90.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 外环半径
    var innerRadius: CGFloat = 65.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 内环标题
    var innerTitle: TextRepresentable? {
        didSet {
            infoView.title = innerTitle
        }
    }
    
    var innerTitleConfig: TPLabelConfig {
        get {
            return infoView.titleConfig
        }
        
        set {
            infoView.titleConfig = newValue
        }
    }
    
    var innerSubtitle: TextRepresentable? {
        didSet {
            infoView.subtitle = innerSubtitle
        }
    }
    
    var innerSubtitleConfig: TPLabelConfig {
        get {
            return infoView.subtitleConfig
        }
        
        set {
            infoView.subtitleConfig = newValue
        }
    }
    
    /// 亮中索引
    var highlightedSliceIndex: Int? {
        if highlightView.isHighlighted {
            return highlightView.highlightedIndex
        }
        
        return nil
    }

    /// 标题标签
    lazy var infoView: TPInfoView = {
        let infoView = TPInfoView()
        infoView.titleConfig.textColor = resGetColor(.title)
        infoView.titleConfig.textAlignment = .center
        infoView.titleConfig.adjustsFontSizeToFitWidth = true
        infoView.titleConfig.font = UIFont.boldSystemFont(ofSize: 24.0)
        infoView.subtitleConfig.textAlignment = .center
        infoView.subtitleConfig.adjustsFontSizeToFitWidth = true
        infoView.subtitleConfig.font = UIFont.boldSystemFont(ofSize: 12.0)
        return infoView
    }()
    
    /// 饼状图
    private let circleView = PieCircleView()
    
    /// 指示线条视图
    private let lineView = PieLineView()
    
    /// 标签视图
    private let labelsView = PieLabelsView()
    
    /// 高亮视图
    private let highlightView = PieHighlightView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        addSubview(lineView)
        addSubview(labelsView)
        addSubview(circleView)
        addSubview(infoView)
        addSubview(highlightView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        let layoutFrame = bounds
        circleView.outerRadius = outerRadius
        circleView.innerRadius = innerRadius
        circleView.frame = layoutFrame
        lineView.radius = outerRadius
        lineView.frame = layoutFrame
        labelsView.radius = outerRadius
        labelsView.frame = layoutFrame
    
        infoView.size = .circleInnerLabelSize(radius: innerRadius - 10.0)
        infoView.center = circleView.center
        
        // 配置高亮视图
        highlightView.outerRadius = outerRadius + 1.0
        highlightView.innerRadius = innerRadius - 1.0
        highlightView.frame = bounds
        
        backgroundColor = .clear
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: 330, height: 280)
    }
    
    // MARK: - Highlight Methods
    
    /// 设置高亮数据
    /// - Parameter index: 要高亮的切片索引
    func setupHighlight(at index: Int) {
        guard let visual = visual else { return }
        highlightView.setup(with: visual, highlightIndex: index)
    }
    
    /// 设置或取消高亮
    /// - Parameter highlighted: true 为高亮，false 为取消高亮
    func setHighlight(_ highlighted: Bool) {
        labelsView.isHidden = highlighted
        lineView.isHidden = highlighted
        highlightView.setHighlighted(highlighted)
    }
    
    /// 高亮指定索引的切片
    /// - Parameters:
    ///   - index: 切片索引
    ///   - animated: 是否显示高亮
    func highlightSlice(at index: Int, animated: Bool = true) {
        setupHighlight(at: index)
        setHighlight(true)
    }
    
    /// 取消高亮
    func clearHighlight() {
        setHighlight(false)
    }
    
    /// 点击后清除高亮
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if highlightView.isHighlighted {
            TPImpactFeedback.impactWithSoftStyle()
            clearHighlight()
        }
    }
}

