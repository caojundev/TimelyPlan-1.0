//
//  TodoTaskMoveSearchResultsSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/8.
//

import Foundation

class TodoTaskMoveSearchResultsSectionController: TPTableSearchResultSectionController {
    
    let viewModel: TodoTaskSectionViewModel
    
    init(viewModel: TodoTaskSectionViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    override func fetchResults(containText text: String, completion: @escaping ([ListDiffable]?) -> Void) {
        viewModel.searchItems(containText: text, completion: completion)
    }
    
    override func heightForHeader() -> CGFloat {
        return 5.0
    }

    override func classForCell(at index: Int) -> AnyClass? {
        let item = item(at: index)
        if item is TodoList {
            return TodoListSearchResultCell.self
        }
        
        return TodoTaskMoveSectionSearchResultCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        if let cell = cell as? TodoListSearchResultCell {
            cell.list = item(at: index) as? TodoList
        } else if let cell = cell as? TodoTaskMoveSectionSearchResultCell {
            cell.section = item(at: index) as? TodoSection
        }
    }
    
    override func didSelectRow(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        let selection = viewModel.selection
        let item = item(at: index)
        if let list = item as? TodoList {
            selection.selectSection(.none(for: list))
        } else if let section = item as? TodoSection {
            selection.selectSection(section)
        }
    }
}
