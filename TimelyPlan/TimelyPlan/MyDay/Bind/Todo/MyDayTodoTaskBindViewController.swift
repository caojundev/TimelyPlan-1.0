//
//  MyDayTodoTaskBindViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/29.
//

import Foundation
import UIKit

class MyDayTodoTaskBindViewController: TPViewController,
                                       TodoTaskSelectViewDelegate {

    lazy var selectView: TodoTaskSelectView = {
        let view = TodoTaskSelectView(frame: view.bounds)
        view.placeholderProvider = viewModel.placeholderProvider
        view.showDetail = true
        view.delegate = self
        return view
    }()
    
    let viewModel = TodoTaskSelectViewModel()
    
    let dateInfo: TaskDateInfo
    
    init(dateInfo: TaskDateInfo) {
        self.dateInfo = dateInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(selectView)
        self.viewModel.onGroupsChanged = { [weak self] in
            self?.groupsChanged()
        }
        
        self.viewModel.loadGroups()
    }
    
    private func groupsChanged() {
        DispatchQueue.main.async {
            self.selectView.groups = self.viewModel.groups
            self.selectView.reloadData()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.selectView.frame = self.view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - TodoTaskSelectViewDelegate
    func todoTaskSelectView(_ view: TodoTaskSelectView, didSelectTask task: TodoTask) {
        TPImpactFeedback.impactWithSoftStyle()
        
        if task.isAddedToMyDay && task.schedule != nil {
            TodoRepository.updateTask(task, isAddedToMyDay: false)
            return
        }
        
        let schedule: TaskSchedule
        if let currentSchedule = task.schedule {
            schedule = currentSchedule
        } else {
            schedule = TaskSchedule(dateInfo: dateInfo,
                                    reminder: nil,
                                    repeatRule: nil)
        }
        
        TodoTaskController.editSchedule(schedule, showClear: false) { newSchedule in
            TodoRepository.updateTask(task,
                                      schedule: newSchedule,
                                      isAddedToMyDay: true)
        }
    }
    
    func todoTaskSelectView(_ view: TodoTaskSelectView, isSelectedTask task: TodoTask) -> Bool {
        return task.isAddedToMyDay && task.schedule != nil
    }
    
}
