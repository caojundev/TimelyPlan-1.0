//
//  TPCountPickerTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/4.
//

import Foundation

class TPCountPickerTableCellItem: TPBaseTableCellItem {

    /// 当前数值
    var count: Int = 0

    /// 最小数目
    var minimumCount: Int = 1

    /// 最大数目
    var maximumCount: Int = 100

    /// 步长
    var stepCount: Int = 1

    var leadingTextForCount: ((Int) -> String?)?
    
    var tailingTextForCount: ((Int) -> String?)?
    
    /// 数目选择回调
    var didPickCount: ((Int) -> Void)?
    
    override init() {
        super.init()
        registerClass = TPCountPickerTableCell.self
        selectionStyle = .none
        height = 180.0
    }
}

class TPCountPickerTableCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPCountPickerTableCellItem else {
                return
            }
            
            pickerView.componentHeight = 55.0
            pickerView.minimumCount = cellItem.minimumCount
            pickerView.maximumCount = cellItem.maximumCount
            pickerView.stepCount = cellItem.stepCount
            pickerView.count = cellItem.count
            pickerView.leadingTextForCount = cellItem.leadingTextForCount
            pickerView.tailingTextForCount = cellItem.tailingTextForCount
            pickerView.reloadData()
        }
    }
    
    var pickerView: TPCountPickerView!
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        pickerView = TPCountPickerView(frame: bounds)
        pickerView.didPickCount = { [weak self] count in
            self?.didPickCount(count)
        }
        
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
