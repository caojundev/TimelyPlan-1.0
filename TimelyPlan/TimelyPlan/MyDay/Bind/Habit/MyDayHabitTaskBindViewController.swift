//
//  MyDayHabitTaskBindViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/27.
//

import Foundation
import UIKit

class MyDayHabitTaskBindViewController: TPViewController,
                                        TPGroupTableViewDelegate {

    lazy var listView: TPGroupTableView = {
        let view = TPGroupTableView(frame: view.bounds, style: .insetGrouped)
        view.delegate = self
        return view
    }()

    lazy var cellStyle: TPTableCellStyle = {
        let style = TPTableCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .tertiarySystemFill
        return style
    }()

    let viewModel = HabitActiveTaskViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.listView)
        let placeholderProvider = viewModel.placeholderProvider
        placeholderProvider.emptyTitle = resGetString("No Habit")
        listView.placeholderProvider = placeholderProvider
        viewModel.tasksDidChange = { [weak self] change in
            self?.tasksChanged(change)
        }
        
        viewModel.loadTasks()
    }
    
    private func tasksChanged(_ change: HabitTaskChange?) {
        DispatchQueue.main.async {
            let group = HabitTaskGroup(identifier: "Tasks")
            group.tasks = self.viewModel.tasks
            self.listView.groups = [group]
            if case .update(_) = change {
                self.listView.performUpdate(with: .none, completion: nil)
                self.listView.updateCheckmarks()
            } else {
                self.listView.reloadData()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.listView.frame = self.view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - TPGroupTableViewDelegate
    func groupTableView(_ tableView: TPGroupTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return MyDayHabitTaskBindCell.self
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didDequeCell cell: UITableViewCell, at indexPath: IndexPath) {
        let cell = cell as! MyDayHabitTaskBindCell
        cell.style = cellStyle
        cell.habitTask = tableView.item(at: indexPath) as? HabitTask
    }
    
    func groupTableView(_ tableView: TPGroupTableView, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        guard let task = tableView.item(at: indexPath) as? HabitTask else {
            return false
        }
        
        return task.isAddedToMyDay
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let task = tableView.item(at: indexPath) as? HabitTask else {
            return
        }
    
        TPImpactFeedback.impactWithSoftStyle()
        
        let isAddedToMyDay = !task.isAddedToMyDay
        HabitRepository.updateTask(task, isAddedToMyDay: isAddedToMyDay)
    }
}
