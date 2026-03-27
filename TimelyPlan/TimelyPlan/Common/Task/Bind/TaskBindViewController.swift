//
//  TaskBindViewController.swift
//  iTimeFlow
//
//  Created by caojun on 2024/2/19.
//

import Foundation
import UIKit

class TaskBindViewController: TPContainerViewController,
                              UISearchControllerDelegate {
    
    /// 当前列表任务类型
    private(set) var taskType: TaskType
    
    /// 允许选择的任务类型
    private(set) var allowTypes = TaskType.allTypes

    /// 当前选中任务
    private(set) var task: TaskFeature?
    
    /// 选中任务回调
    var didSelectTask: ((TaskRepresentable?) -> Void)?
    
    /// 当前任务列表视图控制器
    var listViewController: UIViewController!
 
    /// 搜索控制器
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        let searchBar = searchController.searchBar
        searchBar.placeholder = resGetString("Search Task")
        searchBar.tintColor = Color(light: 0x1F212C, dark: 0xD1DAFF)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.delegate = self
        return searchController
    }()
 
    /// 清除按钮
    private lazy var clearButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: resGetString("Clear"),
                                   style: .done,
                                   target: self,
                                   action: #selector(clickClear(_:)))
        return item
    }()
    
    /// 统计类型菜单
    lazy var typeMenuView: TPSegmentedMenuView = {
        let view = TPSegmentedMenuView()
        view.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        view.buttonHeight = 30.0
        view.minButtonWidth = 60.0
        view.padding = UIEdgeInsets(value: 4.0)
        view.didSelectMenuItem = {[weak self] menuItem in
            if let type = TaskType(rawValue: menuItem.tag) {
                self?.didSelectTaskType(type)
            }
        }
        
        view.menuItems = allowTypes.segmentedMenuItems()
        return view
    }()

    convenience init() {
        self.init(task: nil, type: .habit)
    }
    
    convenience init(task: TaskFeature?) {
        self.init(task: task, type: .habit)
    }
    
    init(task: TaskFeature?,
         type: TaskType,
         allowTypes: [TaskType] = TaskType.allTypes) {
        self.taskType = type
        self.allowTypes = allowTypes
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        if task != nil {
            navigationItem.rightBarButtonItem = clearButtonItem
            navigationItem.rightBarButtonItem?.tintColor = .danger6
        }
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.setupTitleView()
        self.updateContentViewController(with: .none)
    }

    private func setupTitleView() {
        if self.allowTypes.count < 2 {
            if let type = self.allowTypes.first {
                self.title = type.title
            }
        } else {
            typeMenuView.selectMenu(withTag: taskType.rawValue)
            self.navigationItem.titleView = typeMenuView
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.themeDidChange()
    }
    
    /// 选中任务类型
    private func didSelectTaskType(_ taskType: TaskType) {
        if self.taskType == taskType {
            return
        }
        
        let fromIndex = allowTypes.firstIndex(of: self.taskType) ?? 0
        let toIndex = allowTypes.firstIndex(of: taskType) ?? 0
        let animateStyle = SlideStyle.horizontalStyle(fromValue: fromIndex,
                                                      toValue: toIndex)
        self.taskType = taskType
        self.updateContentViewController(with: animateStyle)
    }

    private func updateContentViewController(with style: SlideStyle) {
        self.listViewController = listViewController(for: self.taskType)
        self.setContentViewController(self.listViewController, withAnimationStyle: style)
    }
    
    private func listViewController(for type: TaskType) -> UIViewController! {
        switch type {
        case .habit:
            return createHabitTaskBindViewController()
        default:
            return UIViewController()
        }
    }
    
    /// 创建习惯绑定视图控制器
    private func createHabitTaskBindViewController() -> HabitTaskBindViewController {
        var selectedTaskID: String?
        if let task = task, task.type == .habit {
            selectedTaskID = task.identifier
        }
        
        let vc = HabitTaskBindViewController(selectedTaskID: selectedTaskID)
        vc.didSelectTask = {[weak self] task in
            self?.selectTask(task)
        }
        
        return vc
    }
    
    // MARK: - UISearchControllerDelegate
    func willPresentSearchController(_ searchController: UISearchController) {
        let selectedTaskID = self.task?.identifier
        let resultVC = TaskBindSearchResultViewController(selectedTaskID: selectedTaskID)
        resultVC.didSelectTask = { [weak self] task in
            self?.selectTask(task)
        }
        
        searchController.searchResultsUpdater = resultVC
        self.setContentViewController(resultVC, withAnimationStyle: .none)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        self.setContentViewController(self.listViewController, withAnimationStyle: .none)
    }
     
    // MARK: - Event Response
    @objc private func clickClear(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithMediumStyle()
        self.selectTask(nil)
    }

    private func selectTask(_ task: TaskRepresentable?) {
        self.didSelectTask?(task)
        if let presentingVC = presentingViewController {
            presentingVC.dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Helpers
    static func show(with selectedTask: TaskFeature?,
                     completion: ((TaskRepresentable?) -> Void)?) {
        let vc = TaskBindViewController(task: selectedTask)
        vc.didSelectTask = { task in
            if selectedTask == task?.feature {
                return
            }
            
            completion?(task)
        }
        
        vc.showAsNavigationRoot(style: .formSheet, animated: true, completion: nil)
    }
}
