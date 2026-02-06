//
//  TPTextViewTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/1.
//

import Foundation
import UIKit

class TPTextViewTableCellItem: TPBaseTableCellItem {
    
    /// 文本
    var text: String?
    
    /// 最大输入字符数目
    var maxCount: Int?
    
    /// 输入超出限制是否提示
    var isPromptWhenExceedLimit: Bool = true
    
    /// 占位文本
    var placeholder: String?

    /// 文本容器间距
    var textContainerInset = UIEdgeInsets(horizontal: 0.0, vertical: 10.0)
    
    /// 滑动到边缘时是否有弹性效果
    var bounces: Bool = true
    
    /// 是否显示隐藏键盘按钮
    var shouldShowDismissToolbar = true
    
    /// 是否可滚动
    var isScrollEnabled: Bool = true
    
    /// 是否可以输入换行符号
    var isNewlineEnabled: Bool = true
    
    /// 字体
    var font: UIFont = BOLD_BODY_FONT
    
    /// 文本颜色
    var textColor: UIColor = Color(light: 0x505253, dark: 0xA4A5A6)
    
    /// 占位文本颜色
    var placeholderColor: UIColor = Color(light: 0x505253, dark: 0xA4A5A6, alpha: 0.4)
    
    /// 开始编辑时是否全选所有文本
    var selectAllAtBeginning: Bool = false
    
    /// 返回键类型
    var returnKeyType: UIReturnKeyType = .done
    
    /// 文本编辑改变
    var editingChanged: ((UITextView) -> Void)?
    
    /// 文本输入结束
    var didEndEditing: ((UITextView) -> Void)?
    
    /// 点击Return
    var didEnterReturn: ((UITextView) -> Void)?
    
    /// 光标改变
    var didChangeSelection: ((UITextView) -> Void)?
    
    override init() {
        super.init()
        self.registerClass = TPTextViewTableCell.self
        self.selectionStyle = .none
        self.contentPadding = UIEdgeInsets(value: 5.0)
        self.height = 120.0
        self.didEnterReturn = { textView in
            textView.resignFirstResponder()
        }
    }
    
    /// 文本视图高度（不包含上下边间距）
    var textViewHeight: CGFloat {
        return height - contentPadding.verticalLength
    }
}

class TPAutoResizeTextViewTableCellItem: TPTextViewTableCellItem {
    
    override var isScrollEnabled: Bool {
        get {
            let fitHeight = fitHeight()
            return fitHeight > maximumHeight
        }
        
        set {}
    }
    
    override init() {
        super.init()
        self.bounces = false
        self.setupFitMinimumHeight()
    }
    
    /// 重写高度方法动态计算高度
    override var height: CGFloat {
        get {
            let fitHeight = fitHeight()
            return validatedHeight(fitHeight)
        }
        
        set {
            super.height = newValue
        }
    }
    
    /// 设置最小高度为最佳适配值
    func setupFitMinimumHeight() {
        self.minimumHeight = font.lineHeight + contentPadding.verticalLength + textContainerInset.verticalLength
    }

    /// 计算适配高度
    private func fitHeight() -> CGFloat {
        guard let width = self.cellWidth else {
            return validatedHeight(super.height)
        }

        var layoutWidth = width - textContainerInset.horizontalLength - contentPadding.horizontalLength
        layoutWidth = layoutWidth - leftViewSize.width - leftViewMargins.horizontalLength
        layoutWidth = layoutWidth - rightViewSize.width - rightViewMargins.horizontalLength
        let maxSize = CGSize(width: layoutWidth, height: .greatestFiniteMagnitude)
        let textSize = text?.size(with: font, maxSize: maxSize) ?? .zero
        let contentHeight = textSize.height + textContainerInset.verticalLength + contentPadding.verticalLength
        return contentHeight
    }
    
    private func validatedHeight(_ height: CGFloat) -> CGFloat {
        return min(maximumHeight, max(height, minimumHeight))
    }
}

@objc protocol TPTextViewTableCellDelegate: AnyObject {
    
    /// 文本编辑改变
    @objc optional func textViewTableCell(_ cell: TPTextViewTableCell, editingChanged textView: UITextView)
    
    /// 文本输入结束
    @objc optional func textViewTableCell(_ cell: TPTextViewTableCell, didEndEditing textView: UITextView)
    
    /// 点击Return
    @objc optional func textViewTableCell(_ cell: TPTextViewTableCell, didEnterReturn textView: UITextView)
    
    /// 光标改变
    @objc optional func textViewTableCell(_ cell: TPTextViewTableCell, didChangeSelection textView: UITextView)
}

class TPTextViewTableCell: TPBaseTableCell, UITextViewDelegate  {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPTextViewTableCellItem else {
                return
            }
            
            selectAllAtBeginning = cellItem.selectAllAtBeginning
            isNewlineEnabled = cellItem.isNewlineEnabled
            textView.placeholder = cellItem.placeholder
            textView.placeholderColor = cellItem.placeholderColor
            textView.returnKeyType = cellItem.returnKeyType
            textView.text = cellItem.text
            textView.maxCount = cellItem.maxCount
            textView.isPromptWhenExceedLimit = cellItem.isPromptWhenExceedLimit
            textView.textColor = cellItem.textColor
            textView.isScrollEnabled = cellItem.isScrollEnabled
            textView.font = cellItem.font
            textView.textContainerInset = cellItem.textContainerInset
            textView.bounces = cellItem.bounces
            if cellItem.shouldShowDismissToolbar {
                textView.inputAccessoryView = textView.dismissToolbar
            } else {
                textView.inputAccessoryView = nil
            }
            
            setNeedsLayout()
        }
    }
    
    lazy var textView: TPTextView = {
        let textView = TPTextView()
        textView.delegate = self
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.textContainerInset = .zero
        textView.backgroundColor = .clear
        textView.textContainer.lineFragmentPadding = 0
        textView.layoutManager.allowsNonContiguousLayout = false
        return textView
    }()

    var selectAllAtBeginning: Bool = false
    
    var isNewlineEnabled: Bool = true
    
    /// 是否可滚动
    var isScrollEnabled: Bool {
        if let cellItem = cellItem as? TPTextViewTableCellItem {
            return cellItem.isScrollEnabled
        }
        
        return true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textView.frame = availableLayoutFrame()
        textView.isScrollEnabled = isScrollEnabled
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(textView)
    }

    // MARK: - UITextViewDelegate
    func textViewDidChangeSelection(_ textView: UITextView) {
        if let cellItem = cellItem as? TPTextViewTableCellItem {
            cellItem.didChangeSelection?(textView)
        }
        
        if let delegate = delegate as? TPTextViewTableCellDelegate {
            delegate.textViewTableCell?(self, didChangeSelection: textView)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let cellItem = cellItem as? TPTextViewTableCellItem {
            cellItem.editingChanged?(textView)
        }
        
        if let delegate = delegate as? TPTextViewTableCellDelegate {
            delegate.textViewTableCell?(self, editingChanged: textView)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if selectAllAtBeginning {
            textView.perform(#selector(UITextView.selectAll(_:)),
                              with: textView,
                              afterDelay: 0.1)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let cellItem = cellItem as? TPTextViewTableCellItem {
            cellItem.didEndEditing?(textView)
        }
        
        if let delegate = delegate as? TPTextViewTableCellDelegate {
            delegate.textViewTableCell?(self, didEndEditing: textView)
        }
    }
    
    func textViewDidEnterReturn(_ textView: UITextView) {
        if let cellItem = cellItem as? TPTextViewTableCellItem {
            cellItem.didEnterReturn?(textView)
        }
        
        if let delegate = delegate as? TPTextViewTableCellDelegate {
            delegate.textViewTableCell?(self, didEnterReturn: textView)
        }
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
}
