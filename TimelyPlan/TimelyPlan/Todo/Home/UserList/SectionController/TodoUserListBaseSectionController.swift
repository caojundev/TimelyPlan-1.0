//
//  TodoUserListBaseSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/3.
//

import Foundation
import UIKit

class TodoUserListBaseSectionController: TPTableBaseSectionController,
                                         TPExpandDefaultInfoTableCellDelegate {

    /// 选中列表
    var didSelectList: ((TodoList) -> Void)?
    
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
        return TodoUserListBaseCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        guard let cell = cell as? TodoUserListBaseCell,
              let list = item(at: index) as? TodoList else {
            return
        }

        cell.delegate = self
        cell.style = styleForRow(at: index)
        cell.list = list
        cell.depthLineLevels = TodoList.depthLineLevels(for: list, in: self.lists)
    }

    override func didSelectRow(at index: Int) {
        super.didSelectRow(at: index)
        
        guard let list = item(at: index) as? TodoList else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        self.didSelectList?(list)
    }

    // MARK: - TPExpandDefaultInfoTableCellDelegate
    func isExpandedTableCell(_ cell: TPExpandDefaultInfoTableCell) -> Bool {
        return false
    }
    
    func expandTableCell(_ cell: TPExpandDefaultInfoTableCell, canToggleExpandStateTo isExpanded: Bool) -> Bool {
        return true
    }
    
    func expandTableCell(_ cell: TPExpandDefaultInfoTableCell, didToggleExpand isExpanded: Bool) {
        
    }
    
    // MARK: - Helpers

    /// 当前用户列表
    var lists: [TodoList] {
        if let lists = adapter?.items(for: self) as? [TodoList] {
            return lists
        }

        return []
    }
    
    func list(at index: Int) -> TodoList {
        let list = item(at: index) as! TodoList
        return list
    }
    
}
