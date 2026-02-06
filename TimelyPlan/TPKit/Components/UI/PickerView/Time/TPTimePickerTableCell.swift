//
//  TPTimePickerTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/2.
//

import Foundation

class TPTimePickerTableCellItem: TPBaseTableCellItem {
    
    var didPickDate: ((Date) -> Void)?
    
    var date: Date = .now
    
    override init() {
        super.init()
        registerClass = TPTimePickerTableCell.self
        selectionStyle = .none
        contentPadding = UIEdgeInsets(horizontal: 10.0)
        height = 180.0
    }
}

class TPTimePickerTableCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            reloadData(animated: false)
        }
    }
    
    var pickerView: TPTimePickerView!
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        pickerView = TPTimePickerView(frame: bounds, style: .roundedBorder)
        pickerView.didPickDate = { [weak self] date in
            self?.didPickDate(date)
        }
        
        contentView.addSubview(pickerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pickerView.frame = contentView.layoutFrame()
    }
    
    func didPickDate(_ date: Date) {
        guard let cellItem = cellItem as? TPTimePickerTableCellItem else {
            return
        }
        
        cellItem.date = date
        cellItem.didPickDate?(date)
    }
    
    func reloadData(animated: Bool) {
        guard let cellItem = cellItem as? TPTimePickerTableCellItem else {
            return
        }
        
        cellItem.updater?()
        pickerView.setDate(cellItem.date, animated: animated)
    }
    
}
