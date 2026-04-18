//
//  TodoSmartListSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/4.
//

import Foundation
import UIKit

class TodoSmartListSectionController: TPTableBaseSectionController,
                                      TodoSmartListCellDelegate {
    
    var didSelectList: ((TodoSmartList) -> Void)?
    
    private(set) var types: [TodoSmartListType]
    
    private let viewModel = TodoSmartListViewModel()
    
    override var items: [ListDiffable]? {
        return types.map { type in
            return TodoSmartList(type: type)
        }
    }
    
    init(types: [TodoSmartListType]) {
        self.types = types
        super.init()
        self.viewModel.countDidChange = { [weak self] lists in
            self?.updateTaskCount(for: lists)
        }
    }
    
    /// 更新列表任务数目
    func updateTaskCount(for lists: [TodoSmartList]) {
        for list in lists {
            guard self.types.contains(list.listType) else {
                continue
            }
            
            let diffIdentifier = list.identifier as NSString
            let cell = adapter?.cellForItem(with: diffIdentifier, inSection: self)
            if let cell = cell as? TodoSmartListCell {
                cell.updateTaskCount()
            }
        }
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

        cell.delegate = self
        cell.list = item(at: index) as? TodoSmartList
    }

    override func didSelectRow(at index: Int) {
        super.didSelectRow(at: index)
        TPImpactFeedback.impactWithSoftStyle()
        
        if let list = item(at: index) as? TodoSmartList {
            didSelectList?(list)
        }
    }
    
    // MARK: - TodoSmartListCellDelegate
    func todoSmartListCell(_ cell: TodoSmartListCell, requestCount completion: @escaping (Int?) -> Void) {
        guard let list = cell.list else {
            completion(nil)
            return
        }
        
        viewModel.fetchUncompletedTaskCount(for: list, completion: completion)
    }
}

