//
//  TPNumberFieldTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/9.
//

import Foundation
import UIKit

class TPNumberFieldTableCellItem: TPImageInfoTableCellItem {
    
    var fieldPadding: UIEdgeInsets = UIEdgeInsets(horizontal: 5.0)
    
    var fieldCornerRadius: CGFloat = .greatestFiniteMagnitude

    var number: NSNumber?
    
    var didEndEditing: ((NSNumber) -> Void)?
    
    override init() {
        super.init()
        selectionStyle = .none
        registerClass = TPNumberFieldTableCell.self
        rightViewSize = TPNumberFieldTableCell.numberFieldSize
    }
}

class TPNumberFieldTableCell: TPImageInfoTableCell, TPNumberFieldDelegate {
    
    static let numberFieldSize = CGSize(width: 120, height: 40)
    
    /// 输入框圆角半径
    var fieldCornerRadius: CGFloat = .greatestFiniteMagnitude {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 数字输入控件
    lazy var numberField: TPNumberField = {
        let numberField = TPNumberField()
        numberField.backgroundColor = .tertiarySystemGroupedBackground
        numberField.textField.textColor = resGetColor(.title)
        numberField.selectAllAtBeginning = true
        numberField.delegate = self
        return numberField
    }()
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPNumberFieldTableCellItem else {
                return
            }
            
            fieldCornerRadius = cellItem.fieldCornerRadius
            numberField.number = cellItem.number
            numberField.padding = cellItem.fieldPadding
            numberField.setNeedsLayout()
        }
    }

    /// 更新数字
    func updateNumber() {
        guard let cellItem = cellItem as? TPNumberFieldTableCellItem else {
            return
        }
        
        cellItem.updater?()
        numberField.number = cellItem.number
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        rightView = numberField
        rightViewSize = Self.numberFieldSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        numberField.layer.cornerRadius = min(rightViewSize.halfHeight, fieldCornerRadius)
    }
    
    // MARK: - TPNumberFieldDelegate
    func numberFieldShouldReturn(_ numberField: TPNumberField) -> Bool {
        return true
    }
    
    func numberFieldDidBeginEditing(_ numberField: TPNumberField) {
        
    }
    
    func numberFieldDidEndEditing(_ numberField: TPNumberField) {
        guard let cellItem = cellItem as? TPNumberFieldTableCellItem, let number = numberField.number else {
            return
        }
        
        cellItem.number = number
        cellItem.didEndEditing?(number)
        cellItem.updater?()
        numberField.number = cellItem.number
    }
}

class TPNumberFieldLeftSymbolTableCellItem: TPNumberFieldTableCellItem {

    var leftSymbol: Character?
    
    var leftSymbolSize: CGSize?

    override init() {
        super.init()
        registerClass = TPNumberFieldLeftSymbolTableCell.self
        leftSymbolSize = .mini
    }
}

class TPNumberFieldLeftSymbolTableCell: TPNumberFieldTableCell {

    lazy var leftSymbolLabel: TPLabel = {
        let label = TPLabel()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPNumberFieldLeftSymbolTableCellItem else {
                return
            }
            
            leftSymbolLabel.text = cellItem.leftSymbol?.stringValue
            
            numberField.leftViewSize = cellItem.leftSymbolSize
            numberField.setNeedsLayout()
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        numberField.leftView = leftSymbolLabel
    }
}
