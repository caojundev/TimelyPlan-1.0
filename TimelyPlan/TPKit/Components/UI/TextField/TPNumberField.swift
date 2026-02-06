//
//  TPNumberField.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/9.
//

import Foundation
import UIKit

@objc protocol TPNumberFieldDelegate: AnyObject {
    
    // MARK: - UITextFieldDelegate
    @objc optional func numberFieldShouldReturn(_ numberField: TPNumberField) -> Bool

    /// 开始编辑
    @objc optional func numberFieldDidBeginEditing(_ numberField: TPNumberField)
    
    /// 结束编辑
    @objc optional func numberFieldDidEndEditing(_ numberField: TPNumberField)
}

class TPNumberField: UIView, UITextFieldDelegate {
    
    /// 代理对象
    weak var delegate: TPNumberFieldDelegate?
    
    /// 开始编辑时是否选择所有文本
    var selectAllAtBeginning: Bool = true

    /// 是否是浮点数
    var isFloatNumber: Bool = false {
        didSet {
            updateKeyboardType()
        }
    }
    
    /// 允许输入最大长度
    var maxLength:Int = 6

    var number: NSNumber? {
        set {
            if let number = newValue {
                textField.text = isFloatNumber ? String(number.floatValue) : String(number.intValue)
            } else {
                textField.text = nil
            }
            
            setNeedsLayout()
        }
        
        get {
            guard let text = textField.text?.whitespacesAndNewlinesTrimmedString, !text.isEmpty else {
                return nil
            }
            
            if isFloatNumber {
                guard let floatNumber = Float(text) else {
                    return nil
                }
                
                return NSNumber(value: floatNumber)
            } else {
                guard let intNumber = Int(text) else {
                    return nil
                }
                
                return NSNumber(value: intNumber)
            }
        }
    }
    
    /// 右视图尺寸，为nil时会使用sizeToFit方法设置视图大小
    var rightViewSize: CGSize?

    var rightViewMargins: UIEdgeInsets = .zero
    
    /// 左视图尺寸，为nil时会使用sizeToFit方法设置视图大小
    var leftViewSize: CGSize?

    var leftViewMargins: UIEdgeInsets = .zero
    
    /// 左视图
    var leftView: UIView? {
        didSet {
            guard leftView !== oldValue else {
                return
            }
            
            oldValue?.removeFromSuperview()
            if let leftView = leftView, !leftView.isDescendant(of: self) {
                addSubview(leftView)
            }
            
            setNeedsLayout()
        }
    }

    /// 右视图
    var rightView: UIView? {
        didSet {
            guard rightView !== oldValue else {
                return
            }
            
            oldValue?.removeFromSuperview()
            if let rightView = rightView, !rightView.isDescendant(of: self) {
                addSubview(rightView)
            }
            
            setNeedsLayout()
        }
    }
    
    lazy var dismissToolbar: UIToolbar = {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        let toolbar = UIToolbar(frame: frame)
        toolbar.tintColor = resGetColor(.title)
        let image = resGetImage("keyboard_dismiss_24")
        let clearButton = UIBarButtonItem(image: image,
                                          style: .done,
                                          target: self,
                                          action: #selector(clickDismiss(_:)))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil,
                                            action: nil)
        toolbar.items = [flexibleSpace, clearButton]
        return toolbar
    }()
    
    /// 文本输入框
    private(set) lazy var textField: TPTextField = {
        let textField = TPTextField()
        textField.delegate = self
        textField.contentInsets = UIEdgeInsets(horizontal: 10.0)
        textField.isActionMenuEnabled = false
        textField.returnKeyType = .done
        textField.borderStyle = .none
        textField.textAlignment = .center
        textField.clearButtonMode = .never
        textField.font = BOLD_SYSTEM_FONT
        textField.inputAccessoryView = dismissToolbar
        return textField
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
        self.shouldShowDismissButton = true
        addSubview(textField)
        updateKeyboardType()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        
        var textFieldLeft = layoutFrame.minX
        if let leftView = leftView {
            if let leftViewSize = leftViewSize {
                leftView.size = leftViewSize
            } else {
                leftView.sizeToFit()
            }
            
            leftView.left = layoutFrame.minX + leftViewMargins.left
            leftView.centerY = layoutFrame.midY
            textFieldLeft = layoutFrame.minX + leftView.width + leftViewMargins.horizontalLength
        }
        
        var textFieldRight = layoutFrame.maxX
        if let rightView = rightView {
            if let rightViewSize = rightViewSize {
                rightView.size = rightViewSize
            } else {
                rightView.sizeToFit()
            }
    
            rightView.right = layoutFrame.maxX - rightViewMargins.right
            rightView.centerY = layoutFrame.midY
            
            textFieldRight = layoutFrame.maxX - rightView.width - rightViewMargins.horizontalLength
        }

        textField.top = layoutFrame.minY
        textField.left = textFieldLeft
        textField.width = textFieldRight - textFieldLeft
        textField.height = layoutFrame.height
    }

    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    @objc private func clickDismiss(_ button: UIButton) {
        let _ = textField.resignFirstResponder()
    }
    
    func updateKeyboardType() {
        var keyboardType: UIKeyboardType = .numberPad
        if isFloatNumber {
            keyboardType = .decimalPad
        }
        
        textField.keyboardType = keyboardType
    }
  
    func shouldChangeCharacters(with string: String) -> Bool {
        let isNumber = Int(string) != nil
        let isDecimalPoint = isFloatNumber && string == "."
        return isNumber || isDecimalPoint
    }
    
    // MARK: - TextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var bShouldChange = false
        if range.length > 0 {
            if string.count == 0 {
                /// 删除操作或无替换文本
                bShouldChange = true
            } else {
                /// 替换文本，检查文本是否为数字
                bShouldChange = shouldChangeCharacters(with: string)
            }
        } else if let count = textField.text?.count, count < maxLength {
            /// 输入字符为0
            if let intValue = Int(string), intValue == 0 {
                if !isFloatNumber {
                    /// 整数满足条件：当前文本为空或插入位置非首位并且当前文本值不为0
                    let text = textField.text ?? ""
                    bShouldChange = text.count == 0 || (range.location > 0 && Int(text) != 0);
                } else {
                    /// 小数
                }
            } else if string == "." {
                /// 满足条件（1.浮点数；2.非首位；3.文本框当前是一个整数）
                let isIntValue = textField.text?.isIntValue ?? false
                bShouldChange = isFloatNumber && range.location > 0 && isIntValue
            } else {
                bShouldChange = string.isIntValue;
            }
        }

        return bShouldChange
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let bShouldReturn = delegate?.numberFieldShouldReturn?(self) ?? true
        return bShouldReturn
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        /// 启用键盘隐藏按钮
        if selectAllAtBeginning {
            textField.perform(#selector(UITextField.selectAll(_:)), with: nil, afterDelay: 0.1)
        }
        
        delegate?.numberFieldDidBeginEditing?(self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.numberFieldDidEndEditing?(self)
    }
}
