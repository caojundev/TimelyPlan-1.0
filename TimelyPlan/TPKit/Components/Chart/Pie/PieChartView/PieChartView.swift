//
//  LYCirclePieView.swift
//  LYAdmin
//
//  Created by c.c on 2020/11/10.
//  Copyright © 2020 c.c. All rights reserved.
//

import UIKit

class PieChartView: UIView {
    
    var visual:PieVisual! {
        didSet {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        addSubview(lineView)
        addSubview(labelsView)
        addSubview(circleView)
        addSubview(infoView)
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
        backgroundColor = .clear
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: 330, height: 280)
    }
}

