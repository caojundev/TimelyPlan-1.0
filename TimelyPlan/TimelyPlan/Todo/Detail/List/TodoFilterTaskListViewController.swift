//
//  TodoFilterTaskListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/14.
//

import Foundation

class TodoFilterTaskListViewController: TodoBaseTaskListViewController {

    override func selectListOption(_ option: TodoListOption) {
        if option == .edit {
            self.editFilter()
        } else {
            super.selectListOption(option)
        }
    }
    
    private func editFilter() {
        guard let configuration = self.interactor.configuration as? TodoFilterListConfiguration else {
            return
        }
        
        let filterController = TodoFilterController()
        filterController.editFilter(configuration.filter)
    }
}
