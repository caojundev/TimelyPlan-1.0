//
//  HabitTaskBindViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/27.
//

import Foundation
import UIKit

class HabitTaskBindViewController: TPViewController,
                                   TPLoadableGroupCollectionViewDelegate{

    /// 选中任务回调
    var didSelectTask: ((HabitTask) -> Void)?
    
    /// 当前选中任务标识
    private(set) var selectedTaskID: String?

    lazy var cellStyle: TPCollectionCellStyle = {
        let style = TPCollectionCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .secondarySystemFill
        style.cornerRadius = 12.0
        return style
    }()
    
    lazy var listView: TPGroupCollectionView = {
        let view = TPLoadableGroupCollectionView(frame: view.bounds)
        view.preferredItemHeight = 64.0
        view.delegate = self
        view.refreshHandler = { [weak self] in
            self?.handleRefresh()
        }
        
        return view
    }()
    
    var viewModel = HabitActiveTaskViewModel()
    
    init(selectedTaskID: String?) {
        self.selectedTaskID = selectedTaskID
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
        self.listView.placeholderProvider = placeholderProvider
        self.viewModel.tasksDidChange = { [weak self] change in
            self?.tasksChanged(change)
        }
        
        self.viewModel.loadTasks()
    }
    
    private func handleRefresh() {
        self.viewModel.setNeedsRefresh()
        self.viewModel.loadTasks()
    }
    
    private func tasksChanged(_ change: HabitTaskChange?) {
        let group = HabitTaskGroup(identifier: "Tasks")
        group.tasks = self.viewModel.tasks
        DispatchQueue.main.async {
            self.listView.groups = [group]
            if change != nil {
                self.listView.performUpdate()
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
    
    // MARK: -
    func loadableGroupCollectionView(_ collectionView: TPLoadableGroupCollectionView, forceRefresh: Bool, fetchTaskGroups completion: @escaping ([GroupRepresentable]?) -> Void) {
        habit.fetchActiveTasks { tasks in
            let group = HabitTaskGroup(identifier: "ActiveTasks")
            group.tasks = tasks
            completion([group])
        }
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return HabitTaskBindCell.self
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! HabitTaskBindCell
        cell.cellStyle = cellStyle
        cell.habitTask = collectionView.item(at: indexPath) as? HabitTask
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool {
        guard let task = collectionView.item(at: indexPath) as? HabitTask else {
            return false
        }
        
        return task.identifier == self.selectedTaskID
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let task = collectionView.item(at: indexPath) as? HabitTask else {
            return
        }
    
        TPImpactFeedback.impactWithSoftStyle()
        didSelectTask?(task)
    }
}

