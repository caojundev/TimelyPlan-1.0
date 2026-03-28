//
//  HabitManageBaseListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/5.
//

import Foundation
import UIKit

class HabitManageBaseListViewController: TPViewController,
                                         HabitTaskListViewDelegate,
                                         HabitTaskListInfoCellDelegate {

    private(set) lazy var listView: HabitTaskListView = {
        let view = HabitTaskListView(frame: view.bounds)
        view.delegate = self
        return view
    }()
    
    let taskController = HabitTaskController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.listView)
        self.setupSubviews()
        self.reloadData()
        habit.addUpdater(self, for: .all)
    }
    
    func setupSubviews() {
        
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
    

    // MARK: - Public
    func reloadData() {
        self.listView.reloadData()
    }
    
    // MARK: - HabitTaskListViewDelegate
    func groupsInHabitTaskListView(_ listView: HabitTaskListView) -> [HabitTaskGroup]? {
        return nil
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return HabitTaskListDefaultInfoCell.self
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
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
    
    func habitTaskListView(_ listView: HabitTaskListView, didSelectItemAt indexPath: IndexPath) {
        guard let task = listView.item(at: indexPath) as? HabitTask else {
            return
        }
        
        HabitPresenter.showStats(for: task)
    }
}

extension HabitManageBaseListViewController: HabitTaskProcessorDelegate {
    
    func didCreateHabitTask(_ task: HabitTask) {
        self.listView.performUpdate {[weak self] _ in
            guard let self = self else { return }
            self.listView.revealItem(task)
        }
    }

    func didUpdateHabitTask(_ task: HabitTask) {
        self.listView.performUpdate {[weak self] _ in
            guard let self = self else { return }
            self.listView.revealItem(task)
        }
    }
    
    func didDeleteHabitTask(_ task: HabitTask) {
        self.listView.performUpdate()
    }
    
    func didChangeArchivedState(for task: HabitTask) {
        self.listView.performUpdate()
    }
}
