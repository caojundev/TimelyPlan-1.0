//
//  TPDurationPickerView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/2.
//

import Foundation
import UIKit

class TPDurationPickerView: UIView,
                            TPLoopingPickerViewDataSource,
                            TPLoopingPickerViewDelegate {
    
    /// 选中一个新的时长
    var didPickDuration: ((Int) -> Void)?
    
    var minimumDuration: Int = 0
    var maximumDuration: Int = HOURS_PER_DAY * SECONDS_PER_HOUR - SECONDS_PER_MINUTE
    
    /// 最大小时数
    var maximumHours = HOURS_PER_DAY

    private var _duration: Int = 0
    var duration: Int {
        get {
            return validatedDuration(_duration)
        }
        
        set {
            setDuration(newValue, animated: false)
        }
    }
    
    private let hourComponent: Int = 0
    private let minuteComponent: Int = 1

    /// 部件行高度
    var componentRowHeight: CGFloat = 50.0 {
        didSet {
            pickerView.borderHeight = componentRowHeight
        }
    }
    
    /// 选择器
    private lazy var pickerView: TPLoopingPickerView = {
        let pickerView = TPLoopingPickerView(frame: bounds, style: style)
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    // 小时标签
    private(set) lazy var hourLabel: UILabel = {
        let label = TPLabel()
        label.alpha = 0.8
        label.adjustsFontSizeToFitWidth = true
        label.isUserInteractionEnabled = false
        label.edgeInsets = UIEdgeInsets(left: 5.0, right: 5.0)
        label.font = BOLD_SYSTEM_FONT
        label.textAlignment = .left
        return label
    }()
    
    // 分钟标签
    private(set) lazy var minuteLabel: UILabel = {
        let label = TPLabel()
        label.alpha = 0.8
        label.adjustsFontSizeToFitWidth = true
        label.isUserInteractionEnabled = false
        label.edgeInsets = UIEdgeInsets(left: 10.0, right: 5.0)
        label.font = BOLD_SYSTEM_FONT
        label.textAlignment = .left
        return label
    }()
    
    let style: TPPickerViewStyle
    
    init(frame: CGRect, style: TPPickerViewStyle = .system) {
        self.style = style
        super.init(frame: frame)
        addSubview(pickerView)
        addSubview(hourLabel)
        addSubview(minuteLabel)
        reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pickerView.frame = bounds

        let layoutFrame = bounds.inset(by: pickerView.layoutMargins)
        let labelWidth = 60.0
        hourLabel.width = labelWidth
        hourLabel.height = componentRowHeight
        hourLabel.right = layoutFrame.midX
        hourLabel.alignVerticalCenter()
 
        minuteLabel.sizeEqualToView(hourLabel)
        minuteLabel.right = layoutFrame.maxX
        minuteLabel.alignVerticalCenter()
    }
    
    func updateHourLabel() {
        if duration.hour > 1 {
            hourLabel.text = resGetString("Hours")
        } else {
            hourLabel.text = resGetString("Hour")
        }
    }
    
    func updateMinuteLabel() {
        if duration.minute > 1 {
            minuteLabel.text = resGetString("Mins")
        } else {
            minuteLabel.text = resGetString("Min")
        }
    }
    
    // MARK: - 加载数据
    func reloadData() {
        pickerView.reloadAllComponents()
        updateSelectedRow(for: duration, animated: false)
        updateHourLabel()
        updateMinuteLabel()
    }

    func setDuration(_ duration: Int, animated: Bool) {
        _duration = validatedDuration(duration)
        updateSelectedRow(for: _duration, animated: animated)
        updateHourLabel()
        updateMinuteLabel()
    }
    
    private func updateSelectedRow(for duration: Int, animated: Bool) {
        pickerView.selectRow(duration.hour, inComponent: hourComponent, animated: animated)
        pickerView.selectRow(duration.minute, inComponent: minuteComponent, animated: animated)
    }
    
    private func validatedDuration(_ duration: Int) -> Int {
        return min(max(duration, minimumDuration), maximumDuration)
    }
    
    // MARK: - TPLoopingPickerViewDataSource
    func numberOfComponents(in pickerView: TPLoopingPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: TPLoopingPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == hourComponent {
            return maximumHours
        } else if component == minuteComponent {
            return MINUTES_PER_HOUR
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, numberOfLoopsInComponent component: Int) -> Int {
        return 100
    }
    
    // MARK: - TPLoopingPickerViewDelegate
    func pickerView(_ pickerView: TPLoopingPickerView, widthForComponent component: Int) -> CGFloat {
        return (width - pickerView.layoutMargins.horizontalLength) / 2.0
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return componentRowHeight
    }
 
    func pickerView(_ pickerView: TPLoopingPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView? {
        var label: TPLabel
        if let view = view as? TPLabel {
            label = view
        } else {
            label = TPLabel()
            label.edgeInsets = UIEdgeInsets(right: 60.0)
            label.backgroundColor = .clear
            label.textAlignment = .right
            label.adjustsFontSizeToFitWidth = true
            label.font = UIFont.preferredFont(forTextStyle: .title1)
        }
        
        label.text = String(format: "%l02d", row)
        return label
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard component == hourComponent || component == minuteComponent else {
            return
        }
        
        var hour = duration.hour
        var minute = duration.minute
        if component == hourComponent {
            hour = row
        } else{
            minute = row
        }
        
        var duration = hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE
        let validDuration = validatedDuration(duration)
        if duration != validDuration {
            duration = validDuration
            updateSelectedRow(for: duration, animated: true)
        }
        
        _duration = duration
        
        didPickDuration?(_duration)
        
        updateHourLabel()
        updateMinuteLabel()
    }

}
