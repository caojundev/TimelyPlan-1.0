//
//  TodoUserTaskListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/14.
//

import Foundation

class TodoUserTaskListViewController: TodoBaseTaskListViewController {

    override func performEditOption() {
        guard let configuration = self.interactor.configuration as? TodoUserListConfiguration else {
            return
        }
        
        let listController = TodoUserListController()
        listController.editList(configuration.list)
    }
}
