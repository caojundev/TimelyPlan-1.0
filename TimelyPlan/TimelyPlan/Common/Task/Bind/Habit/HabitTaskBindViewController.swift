//
//  HabitTaskBindViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/27.
//

import Foundation

class HabitTaskBindViewController: TPCollectionSectionsViewController,
                                   TPCollectionSectionControllerDelegate {

    /// 选中任务回调
    var didSelectTask: ((HabitTask) -> Void)?
    
    /// 当前选中任务标识
    private(set) var selectedTaskID: String?

    private lazy var placeholderView: TPDefaultPlaceholderView = {
        let view = TPDefaultPlaceholderView()
        view.isBorderHidden = true
        view.image = resGetImage("habit_plceholder_task_80")
        view.title = resGetString("No Habit")
        view.titleColor = .placeholderText
        return view
    }()
    
    lazy var selectSectionController: HabitTaskBindSectionController = {
        let sectionController = HabitTaskBindSectionController()
        sectionController.delegate = self
        return sectionController
    }()

    init(selectedTaskID: String?) {
        self.selectedTaskID = selectedTaskID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.placeholderView = placeholderView
        self.sectionControllers = [selectSectionController]
        self.loadData()
    }
    
    func loadData() {
        habit.fetchActiveTasks { tasks in
            self.selectSectionController.tasks = tasks
            self.adapter.reloadData()
        }
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - TPCollectionSectionControllerDelegate
    func collectionSectionController(_ sectionController: TPCollectionBaseSectionController, didSelectItemAt index: Int) {
        guard let task = sectionController.item(at: index) as? HabitTask else {
            return
        }
    
        didSelectTask?(task)
    }
    
    func collectionSectionController(_ sectionController: TPCollectionBaseSectionController, shouldShowCheckmarkForItemAt index: Int) -> Bool {
        guard let task = sectionController.item(at: index) as? HabitTask else {
            return false
        }
        
        return task.identifier == self.selectedTaskID
    }
}

