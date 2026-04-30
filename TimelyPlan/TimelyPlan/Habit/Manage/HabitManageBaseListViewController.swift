//
//  HabitManageBaseListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/5.
//

import Foundation
import UIKit

class HabitManageBaseListViewController: TPViewController,
                                         TPGroupCollectionViewDelegate,
                                         HabitTaskListInfoCellDelegate {

    private(set) lazy var listView: TPGroupCollectionView = {
        let view = TPGroupCollectionView(frame: view.bounds)
        view.delegate = self
        return view
    }()
    
    let taskController = HabitTaskController()
    
    var viewModel = HabitActiveTaskViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(listView)
        self.listView.placeholderProvider = viewModel.placeholderProvider
        self.setupSubviews()
        self.viewModel.tasksDidChange = { [weak self] change in
            self?.tasksChanged(change)
        }
        
        self.viewModel.loadTasks()
    }
    
    func setupSubviews() {
        
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
        self.listView.frame = view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    // MARK: - TPGroupCollectionViewDelegate
    func groupCollectionView(_ collectionView: TPGroupCollectionView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return HabitTaskListDefaultInfoCell.self
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! HabitTaskListDefaultInfoCell
        cell.delegate = self
        cell.habitTask = listView.item(at: indexPath) as? HabitTask
    }
    
    // MARK: - HabitTaskListInfoCellDelegate
    func habitTaskListInfoCell(_ cell: HabitTaskListDefaultInfoCell, didClickMore button: UIButton) {
        guard let task = cell.habitTask else {
            return
        }
        
        let menuController = HabitManageTaskMenuController(task: task)
        menuController.didSelectMenuActionType = { type in
            self.performMenuAction(type, forTask: task)
        }
        
        let sourceRect = button.bounds.insetBy(dx: -5.0, dy: -5.0)
        menuController.showMenu(from: button, sourceRect: sourceRect)
    }
    
    func performMenuAction(_ type: HabitTaskMenuActionType, forTask task: HabitTask) {
        switch type {
        case .edit:
            taskController.editTask(task)
        case .archive:
            taskController.archiveTask(task)
        case .unarchive:
            taskController.unarchiveTask(task)
        case .delete:
            taskController.deleteTask(task)
        default:
            break
        }
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let task = listView.item(at: indexPath) as? HabitTask else {
            return
        }
        
        HabitPresenter.showStats(for: task)
    }
}
