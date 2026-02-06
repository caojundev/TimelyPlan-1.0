//
//  TPTPEmojiEditView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/13.
//

import Foundation
import UIKit

class TPEmojiEditView: TPEmojiView, UITextFieldDelegate {

    /// 表情字符发生改变
    var emojiDidChange: ((Character?) -> (Void))?
    
    /// 正常背景色
    var highlightedBackgroundColor: UIColor? = Color(0x888888, 0.2)
    
    /// 表情字符输入框
    private(set) var textField: TPEmojiTextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textField = TPEmojiTextField(frame: self.bounds)
        textField.delegate = self
        textField.isHidden = true
        addSubview(textField)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textField.frame = bounds
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        TPImpactFeedback.impactWithSoftStyle()
        UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {
            self.backgroundColor = self.highlightedBackgroundColor
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {
                self.backgroundColor = self.normalBackgroundColor
            }, completion: nil)
        }
        
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        } else {
            textField.becomeFirstResponder()
        }
    }
    
    func beginEditing() {
        textField.becomeFirstResponder()
    }
    
    func endEditing() {
        textField.resignFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let character = string.first {
            if emoji != character {
                emoji = character
                emojiDidChange?(emoji)
            }
        }
        
        return false
    }
}

