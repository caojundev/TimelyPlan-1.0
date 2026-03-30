//
//  TodoListEmojiNameEditCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/6.
//

import Foundation
import UIKit

class TodoListEmojiNameEditCellItem: TPTextFieldTableCellItem {
    
    /// 表情字符发生改变
    var emojiDidChange: ((Character?) -> (Void))?
    
    /// 表情字符
    var emoji: String?
    
    /// 占位图片
    var placeholderImage: UIImage?
    
    /// 颜色
    var foreColor: UIColor?
    
    override init() {
        super.init()
        self.selectionStyle = .none
        self.registerClass = TodoListNameEmojiEditCell.self
        self.leftViewSize = .size(9)
        self.leftViewMargins = UIEdgeInsets(right: 5.0)
        self.height = 60.0
    }
}

class TodoListNameEmojiEditCell: TPTextFieldTableCell {
    
    lazy var emojiView: TodoListEmojiEditView = {
        let view = TodoListEmojiEditView()
        view.padding = UIEdgeInsets(value: 3.0)
        view.placeholderImage = resGetImage(TodoListLayoutType.list.miniIconName)
        view.emojiDidChange = { [weak self] emoji in
            self?.emojiDidChange(emoji)
        }
        
        return view
    }()
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            let cellItem = cellItem as? TodoListEmojiNameEditCellItem
            emojiView.emoji = cellItem?.emoji?.first
            emojiView.placeholderImage = cellItem?.placeholderImage
            updateColor(cellItem?.foreColor)
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.leftView = self.emojiView
        self.leftViewSize = .size(9)
        self.leftViewMargins = UIEdgeInsets(right: 5.0)
    }
    
    func emojiDidChange(_ emoji: Character?) {
        textField.becomeFirstResponder()
        let cellItem = self.cellItem as? TodoListEmojiNameEditCellItem
        cellItem?.emojiDidChange?(emoji)
    }
    
    /// 更新颜色
    func updateColor(_ color: UIColor?) {
        emojiView.foreColor = color
    }
}
