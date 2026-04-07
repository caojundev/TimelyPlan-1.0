//
//  TodoTagSelectSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/15.
//

import Foundation
import UIKit

class TodoTagSelectSectionController: TPTableBaseSectionController,
                                      TPMultipleItemSelectionUpdater {
    
    var tags: [TodoTag]?
    
    var searchText: String?
    
    let selection: TPMultipleItemSelection<TodoTag>
    
    init(selection: TPMultipleItemSelection<TodoTag>) {
        self.selection = selection
        super.init()
        self.selection.addUpdater(self)
    }

    override var items: [ListDiffable]? {
        return tags
    }
    
    // MARK: - Delegate
    override func heightForHeader() -> CGFloat {
        return 0.0
    }
    
    override func heightForFooter() -> CGFloat {
        return 0.0
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        return 60.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return TodoTagSelectTableCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? TodoTagSelectTableCell else {
            return
        }
        
        cell.userTag = item(at: index) as? TodoTag
        cell.setHighlightedText(self.searchText)
    }
    
    override func didSelectRow(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        guard let tag = item(at: index) as? TodoTag else {
            return
        }
        
        if !selection.isSelectedItem(tag),
           selection.selectedCount >= kTodoTaskMaxTagsCount {
            TodoPresenter.showMaxTagsLimitMessage()
            return
        }
        
        selection.selectItem(tag, autoDeselect: true)
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        guard let tag = item(at: index) as? TodoTag else {
            return false
        }
        
        return selection.isSelectedItem(tag)
    }
    
    func updateSearchTextForVisibleCells() {
        guard let cells = adapter?.visibleCells as? [SearchHighlightable] else {
            return
        }
        
        for cell in cells {
            cell.setHighlightedText(self.searchText)
        }
    }
    
    // MARK: - TPMultipleItemSelectionUpdater
    func multipleItemSelectionDidChange<T>(inserts: Set<T>?, deletes: Set<T>?) where T : Hashable {
        var updateTags = Set<TodoTag>()
        if let inserts = inserts as? Set<TodoTag> {
            updateTags.formUnion(inserts)
        }
        
        if let deletes = deletes as? Set<TodoTag> {
            updateTags.formUnion(deletes)
        }
        
        adapter?.updateCheckmarks(for: Array(updateTags), animated: true)
    }
}

class TodoTagSelectTableCell: TPColorInfoTextValueTableCell,
                                SearchHighlightable {
    
    var userTag: TodoTag? {
        didSet {
            let colorConfig = TPColorAccessoryConfig()
            colorConfig.color = userTag?.color ?? TodoTag.defaultColor
            colorConfig.margins = UIEdgeInsets(left: 5.0, right: 10.0)
            self.colorConfig = colorConfig
            self.updateTitle()
        }
    }
    
     private lazy var checkbox: TPCircularCheckbox = {
         let checkbox = TPCircularCheckbox()
         checkbox.isUserInteractionEnabled = false
         checkbox.outerLineWidth = 1.8
         return checkbox
     }()
     
    // MARK: - SearchHighlightable
    
    /// 高亮文本
    var highlightedText: String?
    
    var searchNormalFont: UIFont {
        return self.titleConfig.font
    }
    
    var searchNormalTextColor: UIColor {
        return self.titleConfig.textColor ?? .label
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.padding = UIEdgeInsets(left: 10.0, right: 10.0)
        rightView = checkbox
        rightViewSize = .size(4)
        rightViewMargins = UIEdgeInsets(left: 5.0, right: 5.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCheckboxStyle()
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkbox.setChecked(checked, animated: animated)
        updateCheckboxStyle()
    }
    
    func updateCheckboxStyle() {
        checkbox.alpha = isChecked ? 1.0 : 0.2
        if isChecked {
            checkbox.innerColor = .primary
        } else {
            checkbox.innerColor = resGetColor(.title)
        }
        
        checkbox.outerColor = checkbox.innerColor
    }
    
    private func updateTitle() {
        guard let tagName = userTag?.name, tagName.count > 0 else {
            self.title = resGetString("Untitled")
            return
        }

        if let highlightedText = highlightedText, highlightedText.count > 0 {
            let value = tagName.attributedStringWithHighlight(highlightedText,
                                                              normalAttributes: normalAttributes,
                                                              highlightAttributes: highlightAttributes)
            self.title = ASAttributedString(value: value)
        } else {
            self.title = tagName
        }
    }

    /// 设置搜索文本并更新高亮显示
    func setHighlightedText(_ highlightedText: String?) {
        self.highlightedText = highlightedText
        self.updateTitle()
    }
}
