//
//  TodoTaskMoveSectionSearchResultCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/8.
//

import Foundation
import UIKit

class TodoTaskMoveSectionSearchResultCell: TPImageInfoTableCell,
                                           SearchHighlightable {

    var section: TodoSection? {
        didSet {
            updateSectionInfo()
            setNeedsLayout()
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentPadding = UIEdgeInsets(left: 12.0, right: 16.0)
        imageConfig.shouldRenderImageWithColor = true
        imageContent = .init(imageName: "todo_section_24")
        imageConfig.margins = UIEdgeInsets(right: 4.0)
    }
    
    func updateSectionInfo() {
        updateInfoTitle()
        
        if let section = section {
            var subtitle: String?
            if let list = section.list {
                subtitle = list.displayName
            } else {
                subtitle = TodoSmartList.inbox.title
            }
            
            infoView.subtitle = subtitle
        }
    }
    
    private func updateInfoTitle() {
        let sectionName = self.section?.name
        if let sectionName = sectionName, let highlightedText = highlightedText, highlightedText.count > 0 {
            let value = sectionName.attributedStringWithHighlight(highlightedText,
                                                                  normalAttributes: normalAttributes,
                                                                  highlightAttributes: highlightAttributes)
            self.infoView.title = ASAttributedString(value: value)
        } else {
            self.infoView.title = sectionName ?? resGetString("Untitled")
        }
    }

    // MARK: - SearchHighlightable
    
    var highlightedText: String?
    
    /// 设置搜索文本并更新高亮显示
    func setHighlightedText(_ highlightedText: String?) {
        self.highlightedText = highlightedText
        self.updateInfoTitle()
    }
}
