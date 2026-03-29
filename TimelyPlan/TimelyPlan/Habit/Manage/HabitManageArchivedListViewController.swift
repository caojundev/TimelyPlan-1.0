//
//  HabitManageArchivedListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/6.
//

import Foundation
import UIKit

class HabitManageArchivedListViewController: HabitManageBaseListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listView.listPlaceholderProvider.emptyImage = resGetImage("archivedList_80")
        self.listView.listPlaceholderProvider.emptyTitle = resGetString("No Archived Habit")
    }
    
    override func habitLoadableTaskListView(_ listView: HabitLoadableTaskListView, forceRefresh: Bool, fetchTaskGroups completion: @escaping ([HabitTaskGroup]?) -> Void) {
        habit.fetchArchivedTasks { tasks in
            let group = HabitTaskGroup(identifier: "Archived")
            group.tasks = tasks
            completion([group])
        }
    }
}
