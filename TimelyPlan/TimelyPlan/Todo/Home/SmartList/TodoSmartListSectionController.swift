//
//  TodoSmartListSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/4.
//

import Foundation
import UIKit

class TodoSmartListSectionController: TPTableBaseSectionController {
    
    var didSelectList: ((TodoSmartList) -> Void)?
    
    private(set) var types: [TodoSmartListType]
    
    override var items: [ListDiffable]? {
        return types.map { type in
            return TodoSmartList(type: type)
        }
    }
    
    init(types: [TodoSmartListType]) {
        self.types = types
        super.init()
    }
    
    // MARK: - Delegate
    override func heightForHeader() -> CGFloat {
        return 0.0
    }
    
    override func heightForFooter() -> CGFloat {
        return 0.0
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        return 55.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return TodoSmartListCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        guard let cell = cell as? TodoSmartListCell else {
            return
        }

        cell.list = item(at: index) as? TodoSmartList
    }

    override func didSelectRow(at index: Int) {
        super.didSelectRow(at: index)
        TPImpactFeedback.impactWithSoftStyle()
        if let list = item(at: index) as? TodoSmartList {
            didSelectList?(list)
        }
    }
}

