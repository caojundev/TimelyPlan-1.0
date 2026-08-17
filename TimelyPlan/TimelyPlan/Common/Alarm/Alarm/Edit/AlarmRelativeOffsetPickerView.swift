//
//  TimeRelativeOffsetPickerView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/11.
//

import Foundation
import UIKit

class AlarmRelativeOffsetPickerView: UIView {
    
    /// 间隔类型
    var intervalType: TaskAlarm.IntervalType = .dayBefore
    
    /// 间隔数目
    var intervalCount: Int = 0
    
    /// 默认为 0
    var offsetDuration: Duration = 0
    
    /// 间隔或时间偏移改变回调
    var valueChanged: ((AlarmRelativeOffsetPickerView) -> Void)?
    
    /// 间隔选择
    private lazy var intervalPickerView: TPCountPickerView = {
        let pickerView = TPCountPickerView(style: .backgroundColorCleared)
        pickerView.tailingLabel.textAlignment = .left
        pickerView.leadingTextForCount = { _ in
            return resGetString("Early")
        }
        
        pickerView.tailingTextForCount = { count in
            return RepeatFrequency.daily.localizedUnit(for: count)
        }
        
        pickerView.didPickCount = { [weak self] count in
            guard let self = self else {
                return
            }
            
            self.intervalCount = count
            self.valueChanged?(self)
        }
        
        return pickerView
    }()
    
    private lazy var offsetPickerView: TPDurationPickerView = {
        let pickerView = TPDurationPickerView(frame: .zero, style: .backgroundColorCleared)
        pickerView.didPickDuration = { [weak self] duration in
            guard let self = self else {
                return
            }
            
            self.offsetDuration = duration
            self.valueChanged?(self)
        }
        
        return pickerView
    }()
    
    /// 指示器图层
    private lazy var borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.primary.cgColor
        layer.lineWidth = 2.4
        layer.opacity = 0.9
        return layer
    }()
    
    let componentHeight: CGFloat = 55.0
    
    /// 边框圆角半径
    let borderCornerRadius: CGFloat = 12.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(intervalPickerView)
        addSubview(offsetPickerView)
        layer.addSublayer(borderLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        intervalPickerView.width = 0.4 * layoutFrame.width
        intervalPickerView.height = layoutFrame.height
        intervalPickerView.origin = layoutFrame.origin
       
        offsetPickerView.width = layoutFrame.width - intervalPickerView.width
        offsetPickerView.height = intervalPickerView.height
        offsetPickerView.top = intervalPickerView.top
        offsetPickerView.left = intervalPickerView.right
        
        let borderLayerY = (bounds.height - componentHeight) / 2.0
        let padding = UIEdgeInsets(horizontal: 10.0)
        let borderLayoutFrame = layoutFrame.inset(by: padding)
        borderLayer.frame = CGRect(x: borderLayoutFrame.minX,
                                   y: borderLayerY,
                                   width: borderLayoutFrame.width,
                                   height: componentHeight)
        borderLayer.path = UIBezierPath(roundedRect: borderLayer.bounds,
                                        cornerRadius: borderCornerRadius).cgPath
    }
    
    func reloadData() {
        intervalPickerView.minimumCount = 0
        intervalPickerView.maximumCount = 30
        intervalPickerView.count = intervalCount
        intervalPickerView.tailingTextForCount = { [weak self] count in
            return self?.intervalType.localizedUnit(for: count)
        }

        intervalPickerView.reloadData()
        
        offsetPickerView.duration = offsetDuration
        offsetPickerView.reloadData()
    }
}
