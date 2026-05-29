//
//  HabitTaskBindViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/27.
//

import Foundation
import UIKit

class HabitTaskBindViewController: TPViewController,
                                   TPGroupTableViewDelegate {

    weak var delegate: TaskBindViewControllerDelegate?
    
    /// 当前选中任务标识
    private(set) var selectedFeature: TaskFeature?

    lazy var cellStyle: TPTableCellStyle = {
        let style = TPTableCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .tertiarySystemFill
        return style
    }()

    lazy var listView: TPGroupTableView = {
        let view = TPGroupTableView(frame: view.bounds, style: .insetGrouped)
        view.delegate = self
        return view
    }()
    
    var viewModel = HabitActiveTaskViewModel()
    
    init(selectedFeature: TaskFeature?) {
        self.selectedFeature = selectedFeature
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        let group = HabitTaskGroup(identifier: "Tasks")
        group.tasks = self.viewModel.tasks
        DispatchQueue.main.async {
            self.listView.groups = [group]
            self.listView.reloadData()
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
        return HabitTaskBindCell.self
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didDequeCell cell: UITableViewCell, at indexPath: IndexPath) {
        let cell = cell as! HabitTaskBindCell
        cell.style = cellStyle
        cell.habitTask = tableView.item(at: indexPath) as? HabitTask
    }
    
    func groupTableView(_ tableView: TPGroupTableView, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        guard let task = tableView.item(at: indexPath) as? HabitTask else {
            return false
        }
        
        return task.identifier == selectedFeature?.identifier
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let task = tableView.item(at: indexPath) as? HabitTask else {
            return
        }
    
        TPImpactFeedback.impactWithSoftStyle()
        selectedFeature = task.feature
        delegate?.taskBindViewController(self, didSelectTask: task)
        tableView.updateCheckmarks()
    }
}

