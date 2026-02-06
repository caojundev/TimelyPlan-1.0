//
//  TodoTaskEditNameTextView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/12.
//

import Foundation

class TodoTaskEditNameTextView: TPStrikethroughTextView,
                                    UITextViewDelegate {
    
    /// 是否全选
    var selectAllAtBeginning: Bool = false
    
    /// 是否允许输入换行符
    var isNewlineEnabled: Bool = false

    /// 文本编辑改变
    var editingChanged: ((UITextView) -> Void)?
    
    /// 文本输入开始
    var didBeginEditing: ((UITextView) -> Void)?
    
    /// 文本输入结束
    var didEndEditing: ((UITextView) -> Void)?
    
    /// 点击Return
    var didEnterReturn: ((UITextView) -> Void)?
    
    /// 光标改变
    var didChangeSelection: ((UITextView) -> Void)?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.delegate = self
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.textContainerInset = .zero
        self.backgroundColor = .clear
        self.textContainer.lineFragmentPadding = 0
        self.layoutManager.allowsNonContiguousLayout = false
        self.isScrollEnabled = true
        self.bounces = true
        self.returnKeyType = .done
        self.strikethroughLineWidth = 2.0
        self.placeholder = resGetString("Add a Task")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if selectAllAtBeginning {
            textView.perform(#selector(UITextView.selectAll(_:)), with: textView, afterDelay: 0.1)
        }
        
        self.didBeginEditing?(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.didEndEditing?(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.setNeedsLayout()
        self.editingChanged?(textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard !isNewlineEnabled else {
            return true
        }
        
        /// 不允许输入换行符
        if text.isNewlineCharacter {
            self.textViewDidEnterReturn(textView)
            return false
        }

        if text.containsNewlineCharacter {
            let replacedText = text.replacingOccurrences(of: "\n", with: " ")
            let string = textView.text ?? ""
            if let stringRange = Range(range, in: string) {
                textView.text = string.replacingCharacters(in: stringRange, with: replacedText)
                /// 手动调用
                textViewDidChange(textView)
            }
            
            return false
        }
            
        return true
    }
    
    func textViewDidEnterReturn(_ textView: UITextView) {
        textView.resignFirstResponder()
        self.didEnterReturn?(textView)
    }
}
