//
//  TPDatePickerTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/1.
//

import Foundation

class TPDatePickerTableCellItem: TPBaseTableCellItem {
    
    /// 日期
    var date: Date =  Date()
    
    /// 选择器模式
    var datePickerMode: UIDatePicker.Mode = .time

    /// 日期选择器数值变化回调
    var dateChanged: ((Date) -> Void)?
    
    override init() {
        super.init()
        registerClass = TPDatePickerTableViewCell.self
        selectionStyle = .none
        height = 180.0
    }
}

class TPDatePickerTableViewCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            reloadData(animated: true)
        }
    }
    
    var pickerView: UIDatePicker!
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        pickerView = UIDatePicker(frame: bounds)
        pickerView.datePickerMode = .time
        pickerView.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        contentView.addSubview(pickerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pickerView.frame = bounds
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        guard let cellItem = cellItem as? TPDatePickerTableCellItem else {
            return
        }
        
        cellItem.dateChanged?(sender.date)
    }
    
    func reloadData(animated: Bool) {
        guard let cellItem = cellItem as? TPDatePickerTableCellItem else {
            return
        }
        
        pickerView.datePickerMode = cellItem.datePickerMode
        pickerView.preferredDatePickerStyle = .wheels
        pickerView.setDate(cellItem.date, animated: animated)
    }
}
