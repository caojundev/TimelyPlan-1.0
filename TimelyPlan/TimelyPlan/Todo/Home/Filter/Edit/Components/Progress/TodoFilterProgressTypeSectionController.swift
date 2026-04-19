//
//  TodoFilterProgressTypeSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/2.
//

import Foundation

class TodoFilterProgressOffSectionController: TPTableItemSectionController {
    
    var didSelectOff: (() -> Void)? {
        didSet {
            offCellItem.didSelectHandler = didSelectOff
        }
    }
    
    lazy var offCellItem: TPCheckmarkTableCellItem = {
        let cellItem = TPCheckmarkTableCellItem()
        cellItem.height = 50.0
        cellItem.title = resGetString("Off")
        return cellItem
    }()
    
    override init() {
        super.init()
        self.cellItems = [offCellItem]
        self.headerItem.height = 5.0
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        let bShow = delegate?.tableSectionController(self, shouldShowCheckmarkForRowAt: index)
        return bShow ?? false
    }
}

class TodoFilterProgressTypeSectionController: TPTableItemSectionController {
    
    var didSelectFilterType: ((TodoProgressFilterType) -> Void)?
    
    override init() {
        super.init()
        self.headerItem.height = 10.0
        var cellItems = [TPCheckmarkTableCellItem]()
        for valueType in TodoProgressFilterType.allCases {
            let cellItem = cellItem(with: valueType)
            cellItems.append(cellItem)
        }
        
        self.cellItems = cellItems
    }
    
    override func didSelectRow(at index: Int) {
        super.didSelectRow(at: index)
        let filterType = filterType(at: index)
        didSelectFilterType?(filterType)
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        let bShow = delegate?.tableSectionController(self, shouldShowCheckmarkForRowAt: index)
        return bShow ?? false
    }
    
    func filterType(at index: Int) -> TodoProgressFilterType {
        guard let cellItem = item(at: index) as? TPCheckmarkTableCellItem,
              let valueType = TodoProgressFilterType(rawValue: cellItem.tag) else {
                  return .setted
        }
        
        return valueType
    }
    
    private func cellItem(with valueType: TodoProgressFilterType) -> TPCheckmarkTableCellItem {
        let cellItem = TPCheckmarkTableCellItem()
        cellItem.contentPadding = UIEdgeInsets(left: 20.0, right: 10.0)
        cellItem.height = 50.0
        cellItem.tag = valueType.rawValue
        cellItem.title = valueType.title
        return cellItem
    }
}
