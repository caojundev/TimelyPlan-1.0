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
    var innerTitle: String? {
        didSet {
            titleLabel.text = innerTitle
        }
    }
    
    /// 标题标签
    lazy var titleLabel: TPLabel = {
        let label = TPLabel()
        label.textColor = resGetColor(.title)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        return label
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
        addSubview(titleLabel)
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
    
        titleLabel.size = .circleInnerLabelSize(radius: innerRadius - 10.0)
        titleLabel.center = circleView.center
        backgroundColor = .clear
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: 330, height: 280)
    }
}

