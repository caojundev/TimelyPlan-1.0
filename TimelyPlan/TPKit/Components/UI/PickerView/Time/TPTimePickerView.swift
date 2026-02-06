//
//  TPTimePickerView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/2.
//

import Foundation
import UIKit

class TPTimePickerView: UIView,
                      TPLoopingPickerViewDataSource,
                      TPLoopingPickerViewDelegate {
    
    /// 日期
    private var _date: Date = Date()
    
    var date: Date {
        get {
            return _date
        }
        
        set {
            setDate(newValue, animated: false)
        }
    }
    
    /// 选中一个新的日期
    var didPickDate: ((Date) -> Void)?
    
    /// 小时
    private(set) var hour: Int = 0
    
    /// 分钟
    private(set) var minute: Int = 0
    
    /// 部件宽度
    var componentWidth: CGFloat = 100.0
    
    /// 部件高度
    var componentHeight: CGFloat = 50.0 {
        didSet {
            pickerView.borderHeight = componentHeight
        }
    }
    
    let style: TPPickerViewStyle
    
    /// 选择器
    private lazy var pickerView: TPLoopingPickerView = {
        let pickerView = TPLoopingPickerView(frame: bounds, style: style)
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    // 时间分割符
    private(set) lazy var separatorLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0.8
        label.isUserInteractionEnabled = false
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.text = ":"
        return label
    }()
    
    init(frame: CGRect, style: TPPickerViewStyle = .system) {
        self.style = style
        super.init(frame: frame)
        hour = date.hour
        minute = date.minute
        pickerView.addSubview(separatorLabel)
        addSubview(pickerView)
        reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pickerView.frame = bounds
        separatorLabel.sizeToFit()
        separatorLabel.alignCenter()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: 300.0, height: 180.0)
    }
    
    // MARK: - 加载数据
    func reloadData() {
        pickerView.reloadAllComponents()
        select(hour: hour, minute: minute, animated: false)
    }

    func select(hour: Int, minute: Int, animated: Bool) {
        self.hour = min(max(0, hour), HOURS_PER_DAY - 1)
        self.minute = min(max(0, minute), MINUTES_PER_HOUR - 1)
        pickerView.selectRow(self.hour, inComponent: 0, animated: animated)
        pickerView.selectRow(self.minute, inComponent: 1, animated: animated)
    }
    
    func setDate(_ date: Date, animated: Bool) {
        _date = date
        hour = date.hour
        minute = date.minute
        select(hour: hour, minute: minute, animated: animated)
    }
    
    // MARK: - TPLoopingPickerViewDataSource
    func numberOfComponents(in pickerView: TPLoopingPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return HOURS_PER_DAY
        } else {
            return MINUTES_PER_HOUR
        }
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, numberOfLoopsInComponent component: Int) -> Int {
        return 100
    }
    
    // MARK: - TPLoopingPickerViewDelegate
    func pickerView(_ pickerView: TPLoopingPickerView, widthForComponent component: Int) -> CGFloat {
        return componentWidth
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return componentHeight
    }
 
    func pickerView(_ pickerView: TPLoopingPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView? {
        var label: TPLabel
        if let view = view as? TPLabel {
            label = view
        } else {
            label = TPLabel()
            label.edgeInsets = UIEdgeInsets(horizontal: 5.0)
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.font = UIFont.preferredFont(forTextStyle: .title1)
        }
        
        label.text = String(format: "%l02d", row)
        return label
    }
    
    func pickerView(_ pickerView: TPLoopingPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            hour = row
        } else {
            minute = row
        }
        
        /// 根据 hour 和 minute 设置date
        if let date = self.date.date(withHour: hour, minute: minute) {
            self.date = date
            didPickDate?(date)
        }
    }
}
