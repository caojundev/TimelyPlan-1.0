//
//  MyDayTaskBindViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/19.
//

import Foundation
import UIKit

class MyDayTaskBindViewController: TPContainerViewController,
                                    UISearchControllerDelegate {
    
    /// 当前列表任务类型
    private(set) var taskType: TaskType
    
    /// 允许选择的任务类型
    private(set) var allowTypes: [TaskType] = [.todo, .habit, .focus]

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

    init(type: TaskType = .todo) {
        self.taskType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
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
        listViewController = listViewController(for: taskType)
        setContentViewController(listViewController, withAnimationStyle: style)
    }
    
    private func listViewController(for type: TaskType) -> UIViewController! {
        switch type {
        case .todo:
            return MyDayTodoTaskBindViewController()
        case .habit:
            return MyDayHabitTaskBindViewController()
        case .focus:
            return MyDayFocusTimerBindViewController()
        default:
            return UIViewController()
        }
    }
    
    // MARK: - UISearchControllerDelegate
    func willPresentSearchController(_ searchController: UISearchController) {
        let resultVC = MyDayTaskBindSearchResultViewController(style: .insetGrouped)
        searchController.searchResultsUpdater = resultVC
        setContentViewController(resultVC, withAnimationStyle: .none)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        setContentViewController(listViewController, withAnimationStyle: .none)
    }
}
