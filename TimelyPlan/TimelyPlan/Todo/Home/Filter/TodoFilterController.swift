//
//  TodoFilterController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/16.
//

import Foundation
import UIKit

class TodoFilterController {
    
    func performMenuAction(with type: TodoFilterMenuActionType, for filter: TodoFilter) {
        switch type {
        case .edit:
            editFilter(filter)
        case .delete:
            deleteFilter(filter)
        }
    }
    
    func createFilter() {
        showFilterEditViewController(with: nil) { editFilter in
            guard let name = editFilter.name, name.count > 0 else {
                return
            }

            todo.createFilter(with: editFilter)
        }
    }
    
    func editFilter(_ filter: TodoFilter) {
        showFilterEditViewController(with: filter.editFilter) { editFilter in
            todo.updateFilter(filter, with: editFilter)
        }
    }
    
    func deleteFilter(_ filter: TodoFilter) {
        let deleteAction = TPAlertAction(type: .destructive,
                                         title: resGetString("Delete")) { action in
            todo.deleteFilter(filter)
        }
        
        let cancelAction = TPAlertAction.cancel
        let format = resGetString("\"%@\" will be permanently deleted. Sure to delete?")
        let filterName = filter.name ?? resGetString("Untitled")
        let message = String(format: format, filterName)
        let alertController = TPAlertController(title: resGetString("Delete Filter"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }
    
    /// 过滤器编辑视图控制器
    private func showFilterEditViewController(with filter: TodoEditFilter?,
                                              completion: ((TodoEditFilter) -> Void)?){
        let vc = TodoFilterEditViewController(filter: filter)
        vc.completion = completion
        vc.showAsNavigationRoot()
    }
    
}
