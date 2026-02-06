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
    var completion: ((Int64) -> Void)?
    
    /// 记录输入类型
    let inputType: TodoRecordInputType
    
    /// 记录输入视图
    let recordInputView: TodoRecordInputView
    
    override var textField: TPTextField {
        return recordInputView.textField
    }
    
    init(inputType: TodoRecordInputType) {
        self.inputType = inputType
        self.recordInputView = TodoRecordInputView(inputType: inputType)
        super.init(title: resGetString("Record"), message: nil, style: .alert, actions: nil)
        self.doneAlertAction.handleBeforeDismiss = true
        self.additionalView = self.recordInputView
        self.additionalSize = CGSize(width: .greatestFiniteMagnitude, height: 55.0)
        self.textField.textAlignment = .left
        self.textField.font = BOLD_BODY_FONT
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func didEndEditing() {
        if let completion = completion {
            if let number = recordInputView.number {
                completion(number.int64Value)
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

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = inputType.image
        imageView.size = .mini
        return imageView
    }()
    
    private lazy var numberField: TPNumberField = {
        let numberField = TPNumberField()
        numberField.selectAllAtBeginning = true
        numberField.clipsToBounds = true
        numberField.leftView = imageView
        numberField.leftViewSize = .mini
        numberField.leftViewMargins = UIEdgeInsets(right: 5.0)
        numberField.padding = UIEdgeInsets(horizontal: 10.0)
        return numberField
    }()
    
    let inputType: TodoRecordInputType
    
    init(inputType: TodoRecordInputType) {
        self.inputType = inputType
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        textField.textColor = resGetColor(.title)
        addSubview(numberField)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let backgroundColor = UIColor.secondarySystemBackground
        numberField.frame = layoutFrame()
        numberField.layer.cornerRadius = 12.0
        numberField.layer.backgroundColor = backgroundColor.cgColor
        
        imageView.updateImage(withColor: resGetColor(.title))
    }
}
