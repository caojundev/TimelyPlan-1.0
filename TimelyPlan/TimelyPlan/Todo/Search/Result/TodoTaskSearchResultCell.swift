//
//  TodoTaskSearchResultCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/24.
//

import Foundation
import UIKit

class TodoTaskSearchResultCell: TodoTaskCheckTableCell,
                                SearchHighlightable {
    
    /// 高亮文本
    var highlightedText: String?
    
    var normalAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: checkInfoView.nameLabel.currentTextColor,
            .font: checkInfoView.nameLabel.font ?? BOLD_SYSTEM_FONT
        ]
    }

    var highlightAttributes: [NSAttributedString.Key: Any] {
        return [
            .backgroundColor: Color(0xFFD60A),
            .foregroundColor: UIColor.black,
            .font: checkInfoView.nameLabel.font ?? BOLD_SYSTEM_FONT
        ]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateHighlightedResult()
    }
    
    func updateHighlightedResult() {
        guard let name = checkInfoView.name, let highlightedText = highlightedText, highlightedText.count > 0 else {
            return
        }
        
        let searchRange = NSString(string: name).range(of: highlightedText)
        if searchRange.location == NSNotFound {
            return
        }
        
        let attributedName = name.attributedStringWithHighlight(highlightedText,
                                                                normalAttributes: normalAttributes,
                                                                highlightAttributes: highlightAttributes)
        self.checkInfoView.attributedName = attributedName
    }
    
    
    /// 设置搜索文本并更新高亮显示
    func setHighlightedText(_ highlightedText: String?) {
        self.highlightedText = highlightedText
        self.reloadData(animated: false)
    }
}
