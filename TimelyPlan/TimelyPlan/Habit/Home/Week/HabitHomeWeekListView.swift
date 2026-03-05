//
//  HabitHomeWeekListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/4.
//

import Foundation
import UIKit

class HabitHomeWeekListView: HabitTaskBaseListView,
                                HabitHomeWeekListCellDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupData() {
        self.sectionLayout.preferredItemHeight = 210.0
    }
    
    /// 聚焦显示任务
    func revealTask(_ task: HabitTask) {
        self.adapter.scrollToItem(task, at: .centeredVertically, animated: true) { _ in
            self.adapter.commitFocusAnimation(for: task)
        }
    }
    
    func performUpdate(with completion: ((Bool) -> Void)? = nil) {
        self.adapter.performUpdate(with: completion)
    }
    
    func reloadCell(forTask task: HabitTask, focusAnimated: Bool = false) {
        self.adapter.reloadCell(forItem: task, focusAnimated: focusAnimated)
    }
    
    override func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        let group = HabitTaskGroup(identifier: "anytime")
        group.iconName = "habit_time_morning_24"
        group.name = "测试分组"
        group.tasks = habit.activeTasks()
        return [group]
    }
    
    // MARK: - HabitHomeWeekListCellDelegate
    func habitHomeWeekListCell(_ cell: HabitHomeWeekListCell, didClickMore button: UIButton) {
        guard let task = cell.task else {
            return
        }
        
        let menuController = HabitHomeTaskMenuViewController()
        menuController.didSelectMenuActionType = { type in
            self.performMenuAction(type, forTask: task)
        }
        
        menuController.showMenu(from: button)
    }
    
    func performMenuAction(_ type: HabitTaskMenuActionType, forTask task: HabitTask) {
        let taskController = HabitTaskController()
        switch type {
        case .edit:
            taskController.editTask(task)
        case .archive:
            taskController.archiveTask(task)
        case .delete:
            taskController.deleteTask(task)
        default:
            break
        }
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return HabitHomeWeekListCell.self
    }

    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let task = adapter.item(at: indexPath) as! HabitTask
        let cell = cell as! HabitHomeWeekListCell
        cell.delegate = self
        cell.task = task
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    // MARK: - Header
    override func adapter(_ adapter: TPCollectionViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        return HabitTaskListGroupHeaderView.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, sizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: .greatestFiniteMagnitude, height: 40.0)
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        if let headerView = headerView as? HabitTaskListGroupHeaderView {
            headerView.group = adapter.object(at: section) as? HabitTaskGroup
        }
    }
}
