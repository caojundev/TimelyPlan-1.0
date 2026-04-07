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
        cell.depthLineLevels = depthLineLevels(for: list, at: index)
    }

    override func didSelectRow(at index: Int) {
        super.didSelectRow(at: index)
        
        guard let list = item(at: index) as? TodoList else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        self.didSelectList?(list)
    }
    
    // MARK: - 深度线条层级
    
    /// 更新可见单元格深度线条层级
    func updateVisibleDepthLineLevels() {
        guard let visibleCells = adapter?.visibleCells, visibleCells.count > 0 else {
            return
        }
        
        for cell in visibleCells {
            if let cell = cell as? TodoUserListBaseCell, let list = cell.list {
                cell.depthLineLevels = depthLineLevels(for: list)
            }
        }
    }
    
    func depthLineLevels(for list: TodoList) -> [Int]? {
        let lists = self.lists
        guard let index = lists.indexOf(list) else {
            /// 当前列表为根列表
            return nil
        }
        
        return depthLineLevels(for: list, at: index)
    }
    
    func depthLineLevels(for list: TodoList, at index: Int) -> [Int]? {
        let lists = self.lists
        let currentDepth = list.depth
        guard currentDepth > 0 else {
            /// 当前列表为根列表
            return nil
        }
        
        /// 最后
        let fromIndex = index + 1
        guard fromIndex < lists.count else {
            return nil
        }
        
        var depths = [Int]()
        var minDepth = Int.max
        for i in fromIndex..<lists.count {
            let list = lists[i]
            let depth = list.depth
            if depth == 0 {
                /// 检查到下一个根列表，跳出循环
                break
            }
            
            if depth > currentDepth {
                /// 深度大于当前深度，检查下一个列表
                continue
            }
            
            if depth <= minDepth {
                depths.append(depth)
            }
            
            /// 设置当前最小深度
            if depth < minDepth {
                minDepth = depth
            }
        }
        
        return depths
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
