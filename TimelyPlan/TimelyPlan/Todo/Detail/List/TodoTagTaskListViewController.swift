//
//  TodoTagTaskListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/14.
//

import Foundation

class TodoTagTaskListViewController: TodoBaseTaskListViewController {

    override func selectListOption(_ option: TodoListOption) {
        if option == .edit {
            self.editTag()
        } else {
            super.selectListOption(option)
        }
    }
    
    private func editTag() {
        guard let configuration = self.interactor.configuration as? TodoTagListConfiguration else {
            return
        }
        
        let tagController = TodoTagController()
        tagController.editTag(configuration.tag)
    }
}
