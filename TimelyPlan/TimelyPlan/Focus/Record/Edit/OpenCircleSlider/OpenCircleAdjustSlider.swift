//
//  OpenCircleScoreView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/28.
//

import Foundation

class OpenCircleAdjustSlider: OpenCircleSlider {

    /// 微调步长
    var adjustStepValue: CGFloat = 1.0
    
    /// 微调视图
    private let adjustView = OpenCircleAdjustButtonView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        padding = UIEdgeInsets(top: 30.0, left: 20.0, bottom: 0.0, right: 20.0)
        adjustView.positiveHandler = { [weak self] in
            self?.adjustProgress(isPositive: true)
        }
        
        adjustView.negativeHandler = { [weak self] in
            self?.adjustProgress(isPositive: false)
        }
        
        progressView.addSubview(adjustView)
        addSubview(progressView)
        valueView.alpha = 0.6
        valueView.fromAngle = progressView.fromAngle
        valueView.toAngle = progressView.toAngle
        addSubview(valueView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
   
        let adjustWidth = progressView.size.width - 2 * progressView.lineWidth
        adjustView.size = CGSize(value: adjustWidth)
        adjustView.alignCenter()
    }

    func adjustProgress(isPositive: Bool) {
        if isPositive {
            progressView.increaseCurrentValue(by: adjustStepValue)
        } else {
            progressView.decreaseCurrentValue(by: adjustStepValue)
        }
    }
}
