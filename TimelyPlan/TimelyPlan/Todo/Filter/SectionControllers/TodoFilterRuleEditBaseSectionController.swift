//
//  TodoFilterRuleEditBaseSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/25.
//

import Foundation

protocol TodoFilterRuleEditSectionControllerDelegate: TPTableSectionControllerDelegate {
    
    func sectionController(_ sectionController: TodoFilterRuleEditBaseSectionController,
                           didChangeFilterRule rule: TodoFilterRule,
                           with filterType: TodoFilterType)
}

class TodoFilterRuleEditBaseSectionController: TPTableItemSectionController {
    
    var isDeleteButtonEnabled: Bool {
        get {
            return filterTypeCellItem.isDeleteButtonEnabled
        }
        
        set {
            filterTypeCellItem.isDeleteButtonEnabled = newValue
        }
    }
    
    private(set) lazy var filterTypeCellItem: TodoFilterRuleEditTypeCellItem = { [weak self] in
        let cellItem = TodoFilterRuleEditTypeCellItem()
        cellItem.identifier = filterType.rawValue
        cellItem.title = filterType.title
        cellItem.imageName = filterType.iconName
        cellItem.updater = {
            self?.updateFilterTypeCellItem()
        }
        
        cellItem.didSelectHandler = {
            self?.selectFilterType()
        }
        
        cellItem.didClickRightButton = { _ in
            self?.clickDelete()
        }
        
        return cellItem
    }()
    
    var filterTypeCell: UITableViewCell? {
        return adapter?.cellForItem(filterTypeCellItem)
    }
    
    var filterRule: TodoFilterRule
    
    let filterType: TodoFilterType
    
    init (rule: TodoFilterRule, type: TodoFilterType) {
        self.filterRule = rule
        self.filterType = type
        super.init()
        self.headerItem.height = 10.0
        setupCellItems()
    }
    
    func setupCellItems() {
        self.cellItems = [filterTypeCellItem]
    }
    
    func updateFilterTypeCellItem() {
        
    }
    
    func selectFilterType() {
        
    }
    
    func clickDelete() {
        
    }
    
    func reloadFilterTypeCell() {
        adapter?.reloadCell(forItem: filterTypeCellItem, with: .none)
    }
    
    func ruleDidChange() {
        if let delegate = delegate as? TodoFilterRuleEditSectionControllerDelegate {
            delegate.sectionController(self, didChangeFilterRule: filterRule, with: filterType)
        }
    }
    
}

class TodoFilterRuleEditTypeCellItem: TPImageInfoRightButtonTableCellItem {
    
    /// 是否为活动状态
    var isActive: Bool = false {
        didSet {
            updateConfig()
        }
    }
    
    var isDeleteButtonEnabled: Bool = true {
        didSet {
            updateConfig()
        }
    }
    
    var normalColor: UIColor = resGetColor(.title)
    
    var activeColor: UIColor = .primary
    
    override init() {
        super.init()
        self.height = 55.0
        self.contentPadding = UIEdgeInsets(horizontal: 10.0)
        self.rightButtonImageName = "xmark_circle_fill_24"
        self.subtitleConfig.font = UIFont.boldSystemFont(ofSize: 10.0)
        self.imageConfig.shouldRenderImageWithColor = false
        self.imageConfig.size = .large
        self.updateConfig()
    }
    
    /// 更新配置
    func updateConfig() {
        if isActive {
            titleConfig.textColor = activeColor
            subtitleConfig.textColor = activeColor
            setDeleteButtonHidden(!isDeleteButtonEnabled)
        } else {
            titleConfig.textColor = normalColor
            subtitleConfig.textColor = normalColor
            setDeleteButtonHidden(true)
        }
    }
    
    func setDeleteButtonHidden(_ isHidden: Bool) {
        if isHidden {
            rightViewSize = .zero
            isRightButtonHidden = true
        } else {
            rightViewSize = .mini
            isRightButtonHidden = false
        }
    }
    
}
