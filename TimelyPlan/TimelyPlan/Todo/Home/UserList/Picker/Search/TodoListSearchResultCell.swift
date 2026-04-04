//
//  TodoListSearchResultCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/8.
//

import Foundation
import UIKit

class TodoListSearchResultCell: TodoUserListSelectCell, SearchHighlightable {
    
    /// 高亮文本
    var highlightedText: String?
    
    var normalAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: infoView.titleConfig.textColor ?? .label,
            .font: infoView.titleConfig.font
        ]
    }

    var highlightAttributes: [NSAttributedString.Key: Any] {
        return [
            .backgroundColor: Color(0xFFD60A),
            .foregroundColor: UIColor.black,
            .font: infoView.titleConfig.font
        ]
    }

    override var list: TodoList? {
        didSet {
            self.depth = 0 /// 深度固定为0
            self.expandButton.isHidden = true /// 隐藏展开按钮
            self.setNeedsLayout()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.contentPadding = UIEdgeInsets(left: 10.0, right: 10.0)
        self.leftView = nil
        self.leftViewSize = .zero
        self.leftViewMargins = .zero
        self.infoView.subtitleConfig.font = .boldSystemFont(ofSize: 12.0)
        self.infoView.subtitleConfig.lineBreakMode = .byTruncatingMiddle
    }
    
    override func updateListInfo() {
        super.updateListInfo()
        updateInfoTitle()
        
        var attributedInfo: ASAttributedString?
        if let parentList = list?.parent, let image = resGetImage("todo_list_parent_24") {
            attributedInfo = .string(image: image,
                                     imageSize: .size(3),
                                     trailingText: parentList.name,
                                     separator: " ")
        }
        
        infoView.subtitle = attributedInfo
    }
    
    private func updateInfoTitle() {
        let listName = self.list?.name
        if let listName = listName, let highlightedText = highlightedText, highlightedText.count > 0 {
            let value = listName.attributedStringWithHighlight(highlightedText,
                                                               normalAttributes: normalAttributes,
                                                               highlightAttributes: highlightAttributes)
            self.infoView.title = ASAttributedString(value: value)
        } else {
            self.infoView.title = listName ?? resGetString("Untitled")
        }
    }

    /// 设置搜索文本并更新高亮显示
    func setHighlightedText(_ highlightedText: String?) {
        self.highlightedText = highlightedText
        self.updateInfoTitle()
    }
}
