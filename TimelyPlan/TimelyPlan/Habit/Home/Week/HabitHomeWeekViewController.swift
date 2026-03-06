//
//  HabitHomeWeekViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/4.
//

import Foundation
import UIKit

class HabitHomeWeekViewController: TPViewController,
                                    HabitHomeWeekListViewDelegate {

    private lazy var listView: HabitHomeWeekListView = {
        let view = HabitHomeWeekListView(frame: view.bounds)
        view.delegate = self
        return view
    }()
    
    /// 添加按钮
    private let addViewSize = CGSize(width: 40.0, height: 40.0)
    private let addViewMargin = 15.0
    private lazy var addView: HabitTaskAddView = {
        let view = HabitTaskAddView()
        view.didClickAdd = { [weak self] button in
            self?.didClickAdd(button)
        }
        
        return view
    }()
    
    private let taskController = HabitTaskController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listView)
        view.addSubview(addView)
        habit.addUpdater(self, for: .all)
        reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeLayoutFrame()
        addView.size = addViewSize
        addView.bottom = layoutFrame.maxY - addViewMargin
        addView.right = layoutFrame.maxX - addViewMargin
        
        listView.frame = view.bounds
        let insetBottom = view.height - addView.top - addViewMargin
        listView.contentInset = UIEdgeInsets(bottom: insetBottom)
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }

    // MARK: - Public
    func reloadData() {
        listView.reloadData()
    }
    
    // MARK: - Event Response
    @objc func didClickAdd(_ button: UIButton){
        taskController.createNewTask()
    }
    
    // MARK: - HabitHomeWeekListViewDelegate
    func habitHomeWeekListView(_ listView: HabitHomeWeekListView, didClickMore button: UIButton, forTask task: HabitTask) {
        let menuController = HabitHomeTaskMenuController()
        menuController.didSelectMenuActionType = { type in
            self.performMenuAction(type, forTask: task)
        }
        
        menuController.showMenu(from: button)
    }
    
    func performMenuAction(_ type: HabitTaskMenuActionType, forTask task: HabitTask) {
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
}

extension HabitHomeWeekViewController: HabitTaskProcessorDelegate {
    
    func didCreateHabitTask(_ task: HabitTask) {
        self.listView.performUpdate {[weak self] _ in
            guard let self = self else { return }
            self.listView.revealTask(task)
        }
    }

    func didUpdateHabitTask(_ task: HabitTask) {
        self.listView.reloadCell(forTask: task, focusAnimated: true)
    }
    
    func didDeleteHabitTask(_ task: HabitTask) {
        self.listView.performUpdate()
    }
    
    func didChangeArchivedState(for task: HabitTask) {
        self.listView.performUpdate()
    }
}
