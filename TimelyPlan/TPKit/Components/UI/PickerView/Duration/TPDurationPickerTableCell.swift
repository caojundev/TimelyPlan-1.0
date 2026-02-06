//
//  TPDurationPickerTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/2.
//

import Foundation

class TPDurationPickerTableCellItem: TPBaseTableCellItem {
    
    var didPickDuration: ((Int) -> Void)?
    
    /// 时长（以秒为单位）
    var duration: Int = 0
    var minimumDuration: Int = 0
    var maximumDuration: Int = Int.max
    
    override init() {
        super.init()
        registerClass = TPDurationPickerTableCell.self
        selectionStyle = .none
        contentPadding = UIEdgeInsets(horizontal: 10.0)
        height = 180.0
    }
}

class TPDurationPickerTableCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            reloadData(animated: false)
        }
    }

    var pickerView: TPDurationPickerView!
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        pickerView = TPDurationPickerView(frame: bounds, style: .roundedBorder)
        pickerView.didPickDuration = { [weak self] duration in
            self?.didPickDuration(duration)
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
    
    func didPickDuration(_ duration: Int) {
        guard let cellItem = cellItem as? TPDurationPickerTableCellItem else {
            return
        }
        
        cellItem.duration = duration
        cellItem.didPickDuration?(duration)
    }
    
    func reloadData(animated: Bool) {
        guard let cellItem = cellItem as? TPDurationPickerTableCellItem else {
            return
        }
        
        cellItem.updater?()
        pickerView.minimumDuration = cellItem.minimumDuration
        pickerView.maximumDuration = cellItem.maximumDuration
        pickerView.setDuration(cellItem.duration, animated: animated)
    }
    
}
