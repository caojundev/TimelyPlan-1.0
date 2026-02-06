//
//  TPEmojiTextField.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/17.
//

import Foundation

class TPEmojiTextField: UITextField {
    
    private let emojiIdentifier = "emoji"
    
    override var textInputContextIdentifier: String? {
        return emojiIdentifier
    }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == emojiIdentifier {
                return mode
            }
        }
        
        return nil
    }
}
