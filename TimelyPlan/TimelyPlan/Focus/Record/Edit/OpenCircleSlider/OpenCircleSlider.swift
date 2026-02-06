//
//  OpenCircleSlider.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/20.
//

import Foundation

class OpenCircleSlider: UIView {

    var value: CGFloat {
        get { return progressView.progress }
        set { progressView.setProgress(newValue, animated: false) }
    }
    
    func setValue(_ value: CGFloat, animated: Bool) {
        progressView.setProgress(value, animated: animated)
    }
    
    var maxValue: CGFloat {
        get { return progressView.toValue }
        set { progressView.toValue = newValue }
    }
    
    var minValue: CGFloat {
        get { return progressView.fromValue }
        set { progressView.fromValue = newValue }
    }
    
    var valueChanged: ((Int) -> Void)? {
        didSet {
            progressView.valueChanged = valueChanged
        }
    }
    
    /// 进度视图
    let progressView = OpenCircleProgressView()
    
    /// 数值视图
    let valueView = OpenCircleValuesView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(top: 30.0, left: 20.0, bottom: 0.0, right: 20.0)
        valueView.alpha = 0.6
        valueView.fromAngle = progressView.fromAngle
        valueView.toAngle = progressView.toAngle
        addSubview(valueView)
        addSubview(progressView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.frame = progressLayoutFrame
        valueView.radius = (progressView.width + progressView.lineWidth) / 2.0
        valueView.frame = progressView.frame
    }
    
    var progressLayoutFrame: CGRect {
        let layoutFrame = self.layoutFrame()
        let r = layoutFrame.shortSideLength / 2.0
        var progressWidth = 2 * r + (1.0 - sqrt(2.0) / 2.0) * r
        progressWidth -= progressView.lineWidth / 2.0
        let x = layoutFrame.minX + (layoutFrame.width - progressWidth) / 2.0
        return CGRect(x: x, y: layoutFrame.minY, size: CGSize(value: progressWidth))
    }
    
    var progressInnerLayoutFrame: CGRect {
        let layoutFrame = progressLayoutFrame
        return layoutFrame.inset(by: UIEdgeInsets(value: progressView.lineWidth))
    }
    
}
