//
//  TPEmojiTextEditTableCellItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation
import UIKit

class TPEmojiTextEditTableCellItem: TPTextFieldTableCellItem {
    
    /// 当前图标
    var emoji: Character?
    
    /// 选中图标回调
    var emojiChanged: ((Character?) -> Void)?
    
    override init() {
        super.init()
        selectionStyle = .none
        registerClass = TPEmojiTextEditTableCell.self
        height = 140.0
    }
}

class TPEmojiTextEditTableCell: TPTextFieldTableCell {
    
    let iconSize = CGSize(width: 60.0, height: 60.0)
    let iconTopMargin = 20.0
    let textFieldTopMargin = 10.0
    let textFieldHeight = 40.0
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            let cellItem = cellItem as! TPEmojiTextEditTableCellItem
            emojiEditView.emoji = cellItem.emoji
        }
    }
    
    /// 图标视图
    lazy var emojiEditView: TPEmojiEditView = {
        let view = TPEmojiEditView()
        view.font = .boldSystemFont(ofSize: 32.0)
        view.backgroundColor = Color(light: 0x252847, dark: 0xFFFFFF, alpha: 0.1)
        view.emojiDidChange = { [weak self] emoji in
            self?.changeEmoji(emoji)
        }
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(emojiEditView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        emojiEditView.size = iconSize
        emojiEditView.cornerRadius = iconSize.height / 2.0
        emojiEditView.top = iconTopMargin
        emojiEditView.alignHorizontalCenter()

        textField.top = emojiEditView.bottom + textFieldTopMargin
        textField.height = textFieldHeight
    }
    
    func changeEmoji(_ emoji: Character?) {
        if let cellItem = cellItem as? TPEmojiTextEditTableCellItem {
            cellItem.emojiChanged?(emoji)
        }
    }
}
