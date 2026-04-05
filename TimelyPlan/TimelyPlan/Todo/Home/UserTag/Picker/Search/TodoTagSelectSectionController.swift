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
    }
    
    override func didSelectRow(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        guard let tag = item(at: index) as? TodoTag else {
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

class TodoTagSelectTableCell: TPColorInfoTextValueTableCell {
    
    var userTag: TodoTag? {
        didSet {
            infoView.title = userTag?.name ?? resGetString("Untitled")
            let colorConfig = TPColorAccessoryConfig()
            colorConfig.color = userTag?.color ?? TodoTag.defaultColor
            colorConfig.margins = UIEdgeInsets(left: 5.0, right: 10.0)
            self.colorConfig = colorConfig
        }
    }
    
     private lazy var checkbox: TPCircularCheckbox = {
         let checkbox = TPCircularCheckbox()
         checkbox.isUserInteractionEnabled = false
         checkbox.outerLineWidth = 1.8
         return checkbox
     }()
     
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
}
