//
//  TodoParentListSearchResultCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/8.
//

import Foundation
import UIKit

class TodoParentListSearchResultCell: TodoUserListSelectCell {

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
        
        var attributedInfo: ASAttributedString?
        if let parentList = list?.parent, let image = resGetImage("todo_list_parent_24") {
            attributedInfo = .string(image: image,
                                     imageSize: .size(3),
                                     trailingText: parentList.name,
                                     separator: " ")
        }
        
        infoView.subtitle = attributedInfo
    }
}
