//
//  TimeOffsetPickerViewCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/15.
//

import Foundation

class TimeOffsetPickerViewCellItem: TPBaseTableCellItem {

    var didChangeTimeOffset: ((TimeOffset) -> Void)?
    
    var timeOffset = TimeOffset()
    
    override init() {
        super.init()
        registerClass = TimeOffsetPickerViewCell.self
        selectionStyle = .none
        height = 160.0
    }
}

class TimeOffsetPickerViewCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TimeOffsetPickerViewCellItem else {
                return
            }
            
            didChangeTimeOffset = cellItem.didChangeTimeOffset
            pickerView.timeOffset = cellItem.timeOffset
            pickerView.reloadData()
        }
    }
    
    var didChangeTimeOffset: ((TimeOffset) -> Void)? {
        get {
            return pickerView.didChangeTimeOffset
        }
        
        set {
            pickerView.didChangeTimeOffset = newValue
        }
    }
    
    var pickerView: TimeOffsetPickerView!
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        pickerView = TimeOffsetPickerView(frame: bounds)
        contentView.addSubview(pickerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pickerView.frame = bounds.inset(by: layoutMargins)
    }
    
    func didPickCount(_ count: Int) {
        guard let cellItem = cellItem as? TPCountPickerTableCellItem else {
            return
        }
        
        cellItem.didPickCount?(count)
    }
}
