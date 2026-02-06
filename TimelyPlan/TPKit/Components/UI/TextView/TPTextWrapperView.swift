//
//  TPTextWrapperView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/25.
//

import Foundation
import UIKit

protocol TPTextWrapperViewDelegate: AnyObject {
    
    /// 输入文本改变
    func textWrapperViewDidChange(_ wrapperView: TPTextWrapperView)

    /// 结束编辑
    func textWrapperViewDidEndEditing(_ wrapperView: TPTextWrapperView)
    
    /// 点击return
    func textWrapperViewDidEnterReturn(_ wrapperView: TPTextWrapperView)
    
    /// 光标位置改变
    func textWrapperViewDidChangeSelection(_ wrapperView: TPTextWrapperView)
}

class TPTextWrapperView: UIView, UITextViewDelegate  {
                         
    var delegate: TPTextWrapperViewDelegate?

    /// 开始编辑时是否全选
    var selectAllAtBeginning: Bool = false
    
    /// 是否可以输入换行符
    var isNewlineEnabled: Bool = true

    /// 占位文本
    var placeholder: String? {
        get {
            return textView.placeholder
        }
        
        set {
            textView.placeholder = newValue
        }
    }
    
    var text: String! {
        get {
            return textView.text
        }
        
        set {
            textView.text = newValue
        }
    }
    
    /// 字体
    var font: UIFont? {
        get {
            return textView.font
        }
        
        set {
            textView.font = newValue
        }
    }
    
    /// 内容尺寸
    var contentSize: CGSize {
        let size = textView.contentSize
        return CGSize(width: size.width + padding.horizontalLength,
                      height: size.height + padding.verticalLength)
    }

    private(set) lazy var textView: TPTextView = {
        let textView = TPTextView(frame: bounds)
        textView.delegate = self
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.textContainerInset = .zero
        textView.backgroundColor = .clear
        textView.textContainer.lineFragmentPadding = 0
        textView.layoutManager.allowsNonContiguousLayout = false
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textView.frame = layoutFrame()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var isFirstResponder: Bool {
        return textView.isFirstResponder
    }
    
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textWrapperViewDidChange(self)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if selectAllAtBeginning {
            textView.perform(#selector(UITextView.selectAll(_:)),
                             with: textView,
                             afterDelay: 0.1)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textWrapperViewDidEndEditing(self)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard !isNewlineEnabled else {
            return true
        }
        
        /// 不允许输入换行符
        if text.isNewlineCharacter {
            delegate?.textWrapperViewDidEnterReturn(self)
            return false
        }

        if text.containsNewlineCharacter {
            let replacedText = text.newlineReplacedWithWhiteSpaceString
            let string = textView.text ?? ""
            if let stringRange = Range(range, in: string) {
                textView.text = string.replacingCharacters(in: stringRange, with: replacedText)
                textViewDidChange(textView) /// 手动调用
            }
            
            return false
        }
            
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        delegate?.textWrapperViewDidChangeSelection(self)
    }
    
}
