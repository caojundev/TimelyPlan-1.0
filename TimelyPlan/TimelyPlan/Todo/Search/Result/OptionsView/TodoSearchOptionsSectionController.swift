//
//  TodoSearchOptionsSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/26.
//

import Foundation
import UIKit

enum TodoSearchOptionType: String, TPMenuRepresentable {
    case completed
    case step
    case note
    case filter
    
    var iconName: String? {
        return "todo_search_option_\(rawValue)_16"
    }
}

class TodoSearchOptionsSectionController: TPCollectionItemSectionController {
    
    var optionsChanged: ((TodoSearchOptions) -> Void)?

    /// 已完成
    lazy var completedCellItem: TodoSearchOptionCellItem = { [weak self] in
        let cellItem = TodoSearchOptionCellItem(optionType: .completed)
        cellItem.updater = {
            guard let self = self else { return }
            self.completedCellItem.isActive = self.options.showCompleted
        }
        
        return cellItem
    }()
    
    /// 步骤
    lazy var stepCellItem: TodoSearchOptionCellItem = { [weak self] in
        let cellItem = TodoSearchOptionCellItem(optionType: .step)
        cellItem.updater = {
            guard let self = self else { return }
            self.stepCellItem.isActive = self.options.searchStep
        }
        
        return cellItem
    }()
    
    
    /// 备注
    lazy var noteCellItem: TodoSearchOptionCellItem = { [weak self] in
        let cellItem = TodoSearchOptionCellItem(optionType: .note)
        cellItem.updater = {
            guard let self = self else { return }
            self.noteCellItem.isActive = self.options.searchNote
        }
        
        return cellItem
    }()
    
    /// 过滤器
    lazy var filterCellItem: TodoSearchOptionCellItem = { [weak self] in
        let cellItem = TodoSearchOptionCellItem(optionType: .filter)
        cellItem.updater = {
            guard let self = self else { return }
            if let rule = self.options.filterRule, rule.isValid {
                self.filterCellItem.isActive = true
            } else {
                self.filterCellItem.isActive = false
            }
        }
        
        return cellItem
    }()
    
    private(set) var options: TodoSearchOptions

    init(options:TodoSearchOptions) {
        self.options = options
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 18.0, vertical: 0.0)
        self.layout.lineSpacing = 10.0
        self.layout.interitemSpacing = 10.0
        self.cellItems = [completedCellItem,
                          stepCellItem,
                          noteCellItem,
                          filterCellItem]
    }
    
    override func didSelectItem(at index: Int) {
        super.didSelectItem(at: index)
        guard let cellItem = item(at: index) as? TodoSearchOptionCellItem else {
            return
        }
        
        switch cellItem.optionType {
        case .completed:
            selectCompleted()
        case .step:
            selectStep()
        case .note:
            selectNote()
        case .filter:
            selectFilter()
        }
    }

    // MARK: - Updat
    func reload(for optionType: TodoSearchOptionType) {
        var cellItem: TodoSearchOptionCellItem?
        switch optionType {
        case .completed:
            cellItem = completedCellItem
        case .step:
            cellItem = stepCellItem
        case .note:
            cellItem = noteCellItem
        case .filter:
            cellItem = filterCellItem
        }
        
        if let cellItem = cellItem {
            adapter?.reloadCell(forItem: cellItem)
        }
    }
    
    // MARK: - Menu Action
    private func selectCompleted() {
        options.showCompleted = !options.showCompleted
        optionsChanged?(options)
        reload(for: .completed)
    }
    
    private func selectStep() {
        options.searchStep = !options.searchStep
        optionsChanged?(options)
        reload(for: .step)
    }
    
    private func selectNote() {
        options.searchNote = !options.searchNote
        optionsChanged?(options)
        reload(for: .note)
    }
    
    private func selectFilter() {
        let editVC = TodoSearchFilterRuleEditViewController(rule: options.filterRule)
        editVC.didEndEditing = { rule in
            self.filterRuleDidEndEditing(rule)
        }
        
        editVC.didClickClear = {
            self.filterRuleDidEndEditing(nil)
        }
        
        editVC.showAsNavigationRoot()
    }
    
    private func filterRuleDidEndEditing(_ rule: TodoFilterRule?) {
        guard options.filterRule != rule else {
            return
        }
        
        options.filterRule = rule
        optionsChanged?(options)
        reload(for: .filter)
    }
}

class TodoSearchOptionCellItem: TPImageInfoCollectionCellItem {
    
    var isActive: Bool = false {
        didSet {
            updateStyle(isActive: isActive)
        }
    }
    
    /// 单元格样式
    lazy var cellStyle: TPCollectionCellStyle = {
        let style = TPCollectionCellStyle()
        style.cornerRadius = 8.0
        return style
    }()
    
    override var size: CGSize? {
        get {
            var width = contentPadding.horizontalLength
            width += imageConfig.size.width + imageConfig.margins.horizontalLength
            width += rightAccessorySize.width + rightAccessoryMargins.horizontalLength
            var titleWidth: CGFloat = 0.0
            if let attributedTitle = title as? ASAttributedString {
               titleWidth = attributedTitle.value.width(with: titleConfig.font)
            } else if let title = title as? String{
                titleWidth = title.width(with: titleConfig.font)
            }
        
            width += titleWidth
            return CGSize(width: width, height: 32.0)
        }
        
        set {}
    }
    
    let optionType: TodoSearchOptionType
    
    init(optionType: TodoSearchOptionType) {
        self.optionType = optionType
        super.init()
        imageName = optionType.iconName
        title = optionType.title
        scaleWhenHighlighted = false
        contentPadding = UIEdgeInsets(left: 8.0, right: 16.0)
        style = cellStyle
        imageConfig.size = .size(4)
        imageConfig.shouldRenderImageWithColor = true
        imageConfig.margins = UIEdgeInsets(right: 4.0)
        titleConfig.font = .boldSystemFont(ofSize: 12.0)
        rightAccessorySize = .zero
        rightAccessoryMargins = .zero
        updateStyle(isActive: false)
    }
    
    private func updateStyle(isActive: Bool) {
        let textColor: UIColor = isActive ? .white : Color(light: 0x646566, dark: 0xabacad)
        titleConfig.textColor = textColor
        imageConfig.color = textColor
        
        let backgroundColor: UIColor = isActive ? .primary : .secondarySystemGroupedBackground
        cellStyle.backgroundColor = backgroundColor
        cellStyle.selectedBackgroundColor = backgroundColor
    }
    
}
