//
//  OpenCircleTitleView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/28.
//

import Foundation

class OpenCircleValuesView: UIView {
    
    var radius: CGFloat = 0.0

    var fromAngle: CGFloat = -230.0

    var toAngle: CGFloat = 50.0

    /// 标题视图
    private var titleViews: [OpenCircleTitleView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        let titles = ["00", "20", "40", "60", "80", "100"]
        for (index, title) in titles.enumerated() {
            let titleView = OpenCircleTitleView()
            titleView.tag = index
            titleView.title = title
            titleViews.append(titleView)
            addSubview(titleView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for (index, titleView) in titleViews.enumerated() {
            titleView.layer.setAffineTransform(CGAffineTransform.identity)
            titleView.width = 80.0
            titleView.height = radius
            titleView.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
            titleView.alignHorizontalCenter()
            titleView.bottom = self.halfHeight
            
            let stepAngle = (fromAngle - toAngle) / CGFloat(titleViews.count - 1)
            let currentAngle = fromAngle - stepAngle * CGFloat(index)
            let rotateAngle = currentAngle + 90.0
            titleView.rotateAngle = rotateAngle
            titleView.transform = CGAffineTransform(rotationAngle: rotateAngle.degreesToRadians)
        }
    }
}

class OpenCircleTitleView: UIView {
    
    var textLabel: UILabel!
    
    var title: String = "" {
        didSet {
            textLabel.text = title
            setNeedsLayout()
        }
    }
    
    var rotateAngle: CGFloat = 0 {
        didSet {
            if rotateAngle != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = false
        textLabel = UILabel()
        textLabel.numberOfLines = 2
        textLabel.textAlignment = .center
        textLabel.font = BOLD_SMALL_SYSTEM_FONT
        textLabel.text = "Normal"
        addSubview(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel.layer.setAffineTransform(CGAffineTransform.identity)
        textLabel.sizeToFit()
        textLabel.width = bounds.width
        textLabel.layer.setAffineTransform(CGAffineTransform(rotationAngle: -rotateAngle.degreesToRadians))
    }
}


