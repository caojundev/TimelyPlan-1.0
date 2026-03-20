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
        self.listView.placeholderConfiguration = { view in
            view.image = resGetImage("archivedList_80")
            view.title = resGetString("No Archived Habit")
        }
    }
    
    override func groupsInHabitTaskListView(_ listView: HabitTaskListView) -> [HabitTaskGroup]? {
        let group = HabitTaskGroup(identifier: "Archived")
        group.tasks = habit.archivedTasks()
        return [group]
    }
}
