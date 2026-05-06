//
//  TodoFilterTaskListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/14.
//

import Foundation

class TodoFilterTaskListViewController: TodoBaseTaskListViewController {

    override func performEditOption() {
        guard let configuration = self.interactor.configuration as? TodoFilterListConfiguration else {
            return
        }
        
        let filterController = TodoFilterController()
        filterController.editFilter(configuration.filter)
    }
}
