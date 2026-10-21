//
//  TaskBindSearchResultViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/30.
//

import Foundation
import UIKit

class TaskBindSearchResultViewController: TPTableSectionsViewController,
                                          UISearchResultsUpdating, TPTableSectionControllerDelegate {

    weak var delegate: TaskBindViewControllerDelegate?
    
    /// 当前选中任务特征值
    private(set) var selectedTaskFeature: TaskFeature?
    
    /// 允许搜索的任务类型
    private(set) var allowTypes: [TaskType]
 
    lazy var todoResultSectionController: TodoTaskBindSearchResultSectionController = {
        let sectionController = TodoTaskBindSearchResultSectionController()
        sectionController.delegate = self
        return sectionController
    }()
 
    lazy var habitResultSectionController: HabitTaskBindSearchResultSectionController = {
        let sectionController = HabitTaskBindSearchResultSectionController()
        sectionController.delegate = self
        return sectionController
    }()
    
    lazy var goalResultSectionController: GoalTaskBindSearchResultSectionController = {
        let sectionController = GoalTaskBindSearchResultSectionController()
        sectionController.delegate = self
        return sectionController
    }()
    
    lazy var countdownResultSectionController: CountdownEventBindSearchResultSectionController = {
        let sectionController = CountdownEventBindSearchResultSectionController()
        sectionController.delegate = self
        return sectionController
    }()
    
    init(selectedTaskFeature: TaskFeature?,
         allowTypes: [TaskType] = [.todo, .habit, .goal, .countdown]) {
        self.selectedTaskFeature = selectedTaskFeature
        self.allowTypes = allowTypes
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let provider = TPDefaultPlaceholderProvider()
        provider.emptyImage = resGetImage("placeholder_noSearchResult_80")
        wrapperView.placeholderProvider = provider
        wrapperView.shouldShowPlaceholder = { [weak self] in
            guard let self = self else { return false }
            return !self.adapter.hasItem
        }
    
        wrapperView.isKeyboardAdjusterEnabled = true
        wrapperView.keyboardDismissMode = .onDrag
        sectionControllers = makeSectionControllers()
        reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    /// 按允许的任务类型组装搜索分组
    private func makeSectionControllers() -> [TPTableBaseSectionController] {
        var sectionControllers: [TPTableBaseSectionController] = []
        if allowTypes.contains(.todo) {
            sectionControllers.append(todoResultSectionController)
        }
        
        if allowTypes.contains(.habit) {
            sectionControllers.append(habitResultSectionController)
        }
        
        if allowTypes.contains(.goal) {
            sectionControllers.append(goalResultSectionController)
        }
        
        if allowTypes.contains(.countdown) {
            sectionControllers.append(countdownResultSectionController)
        }
        
        return sectionControllers
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        guard let sectionControllers = sectionControllers as? [UISearchResultsUpdating] else {
            return
        }
        
        for sectionController in sectionControllers {
            sectionController.updateSearchResults(for: searchController)
        }
    }
    
    
    // MARK: - TPTableSectionControllerDelegate
    func tableSectionController(_ sectionController: TPTableBaseSectionController, didSelectRowAt index: Int) {
        guard let task = sectionController.item(at: index) as? TaskRepresentable else {
            return
        }

        self.selectedTaskFeature = task.feature
        adapter.updateCheckmarks(animated: true)
        delegate?.taskBindViewController(self, didSelectTask: task)
    }
    
    func tableSectionController(_ sectionController: TPTableBaseSectionController, shouldShowCheckmarkForRowAt index: Int) -> Bool {
        guard let task = sectionController.item(at: index) as? TaskRepresentable else {
            return false
        }

        return task.feature == selectedTaskFeature
    }
}

