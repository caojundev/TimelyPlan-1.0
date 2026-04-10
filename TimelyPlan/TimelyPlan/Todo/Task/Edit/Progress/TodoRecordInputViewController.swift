//
//  TodoRecordInputViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/3/29.
//

import Foundation
import UIKit

class TodoRecordInputViewController: TPTextFieldAlertController {
    
    /// 完成回调
    var completion: ((Int64, TodoRecordInputType) -> Void)?
    
    /// 记录输入类型
    var inputType: TodoRecordInputType {
        get {
            return recordInputView.inputType
        }
        
        set {
            recordInputView.inputType = newValue
        }
    }
    
    /// 记录输入视图
    lazy var recordInputView: TodoRecordInputView = {
        let view = TodoRecordInputView()
        view.inputTypeDidChange = { [weak self] in
            self?.updateDoneActionEnabled()
        }
        
        return view
    }()
    
    init() {
        let title = resGetString("Record")
        super.init(title: title, message: nil, style: .alert, actions: nil)
        self.actionsCountPerRow = 1
        self.actions = [doneAlertAction]
        self.textField.textAlignment = .center
        self.textField.font = UIFont.boldSystemFont(ofSize: 16.0)
        self.additionalView = self.recordInputView
        self.additionalSize = CGSize(width: .greatestFiniteMagnitude, height: 130.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override var textField: TPTextField {
        return recordInputView.textField
    }
    
    override func clickDone() {
        /// dismiss 完成后通知结束编辑
        dismiss(animated: true) {
            self.didEndEditing()
        }
    }
    
    override func didEndEditing() {
        if let completion = completion {
            if let number = recordInputView.number {
                completion(number.int64Value, inputType)
            }
        } else {
            super.didEndEditing()
        }
    }
}


class TodoRecordInputView: UIView {
    
    var number: NSNumber? {
        return numberField.number
    }
    
    var textField: TPTextField {
        return numberField.textField
    }
    
    var inputTypeDidChange: (() -> Void)?
    
    var inputType: TodoRecordInputType {
        get {
            let tag = typeMenuView.selectedMenuTag ?? 0
            return TodoRecordInputType(rawValue: tag) ?? .increase
        }
        
        set {
            typeMenuView.selectMenu(withTag: newValue.rawValue)
        }
    }
    
    /// 开始/结束菜单视图
    private lazy var typeMenuView: TPSegmentedMenuView = {
        let view = TPSegmentedMenuView()
        view.cornerRadius = 16.0
        view.margin = 0.0
        view.padding = UIEdgeInsets(value: 5.0)
        view.didSelectMenuItem = { [weak self] menuItem in
            if let type = TodoRecordInputType(rawValue: menuItem.tag) {
                self?.selectInputType(type)
            }
        }
        
        view.menuItems = TodoRecordInputType.segmentedMenuItems()
        return view
    }()
    
    private lazy var numberField: TPNumberField = {
        let numberField = TPNumberField()
        numberField.selectAllAtBeginning = false
        numberField.clipsToBounds = true
        return numberField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        addSubview(typeMenuView)
        addSubview(numberField)
        updateTextField()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let backgroundColor = Color(light: 0x666666, dark: 0xaaaaaa, alpha: 0.1)
        self.padding = UIEdgeInsets(top: 10.0)
        let layoutFrame = layoutFrame()
    
        typeMenuView.width = width
        typeMenuView.height = 55.0
        typeMenuView.minButtonWidth = (width - typeMenuView.padding.horizontalLength) / CGFloat(typeMenuView.menuItems.count)
        typeMenuView.top = layoutFrame.minY
        typeMenuView.normalBackgroundColor = backgroundColor
        
        numberField.width = width
        numberField.height = 55.0
        numberField.top = typeMenuView.bottom + 10.0
        numberField.layer.cornerRadius = 12.0
        numberField.layer.backgroundColor = backgroundColor.cgColor
    }
    
    private func selectInputType(_ type: TodoRecordInputType) {
        updateTextField()
        inputTypeDidChange?()
    }
    
    func updateTextField() {
        var placeholder = ""
        if inputType == .update {
            placeholder = resGetString("Update the number of records")
        } else if inputType == .increase {
            placeholder = resGetString("Increase the number of records")
        } else if inputType == .decrease {
            placeholder = resGetString("Decrease the number of records")
        }
        
        textField.placeholder = placeholder
        textField.text = nil
    }
}
