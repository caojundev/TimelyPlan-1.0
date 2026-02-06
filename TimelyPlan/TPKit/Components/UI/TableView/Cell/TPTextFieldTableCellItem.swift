//
//  TPTextFieldTableCellItem.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/31.
//

import Foundation
import UIKit

class TPTextFieldTableCellItem: TPBaseTableCellItem {
    
    /// 文本
    var text: String?
    
    /// 占位文本
    var placeholder: String?
    
    /// 文本对齐方式
    var textAlignment: NSTextAlignment = .left

    /// 字体
    var font: UIFont = UIFont.preferredFont(forTextStyle: .title3).withBold()
    
    /// 清除按钮模式
    var clearButtonMode: UITextField.ViewMode = .whileEditing

    /// 开始编辑时是否全选所有文本
    var selectAllAtBeginning: Bool = false
    
    /// 文本编辑改变
    var editingChanged: ((UITextField) -> Void)?
    
    /// 文本输入结束
    var didEndEditing: ((UITextField) -> Void)?
    
    /// 点击Return
    var didEnterReturn: ((UITextField) -> Void)?
    
    override init() {
        super.init()
        self.selectionStyle = .none
        self.registerClass = TPTextFieldTableCell.self
        self.didEnterReturn = { textField in
            textField.resignFirstResponder()
        }
    }
}

@objc protocol TPTextFieldTableCellDelegate: AnyObject {
    
    /// 文本编辑改变
    @objc optional func textFieldTableCell(_ cell: TPTextFieldTableCell, editingChanged textField: UITextField)
    
    /// 文本输入结束
    @objc optional func textFieldTableCell(_ cell: TPTextFieldTableCell, didEndEditing textField: UITextField)
    
    /// 点击Return
    @objc optional func textFieldTableCell(_ cell: TPTextFieldTableCell, didEnterReturn textField: UITextField)
}

class TPTextFieldTableCell: TPBaseTableCell, UITextFieldDelegate {

    var selectAllAtBeginning: Bool = false

    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPTextFieldTableCellItem else {
                return
            }
            
            selectAllAtBeginning = cellItem.selectAllAtBeginning
            textField.text = cellItem.text
            textField.placeholder = cellItem.placeholder
            textField.textAlignment = cellItem.textAlignment
            textField.clearButtonMode = cellItem.clearButtonMode
            textField.font = cellItem.font
        }
    }
    
    private(set) var textField: UITextField!
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        selectionStyle = .none
        textField = UITextField()
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        textField.returnKeyType = .done
        contentView.addSubview(textField)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textField.frame = availableLayoutFrame()
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let cellItem = cellItem as? TPTextFieldTableCellItem {
            cellItem.didEnterReturn?(textField)
        }
        
        if let delegate = delegate as? TPTextFieldTableCellDelegate {
            delegate.textFieldTableCell?(self, didEnterReturn: textField)
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if selectAllAtBeginning {
            textField.perform(#selector(UITextField.selectAll(_:)), with: textField, afterDelay: 0.1)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let cellItem = cellItem as? TPTextFieldTableCellItem {
            cellItem.didEndEditing?(textField)
        }
        
        if let delegate = delegate as? TPTextFieldTableCellDelegate {
            delegate.textFieldTableCell?(self, didEndEditing: textField)
        }
    }
    
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        if let cellItem = cellItem as? TPTextFieldTableCellItem {
            cellItem.editingChanged?(textField)
        }
        
        if let delegate = delegate as? TPTextFieldTableCellDelegate {
            delegate.textFieldTableCell?(self, editingChanged: textField)
        }
    }
    
    override func updateCellStyle() {
        super.updateCellStyle()
        textField.textColor = resGetColor(.title)
    }
}

