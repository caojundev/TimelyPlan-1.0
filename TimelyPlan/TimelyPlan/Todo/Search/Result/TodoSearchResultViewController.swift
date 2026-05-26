//
//  TodoSearchResultViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/24.
//

import Foundation
import UIKit

class TodoSearchResultViewController: TPViewController,
                                      TodoTaskListViewDelegate,
                                      UISearchResultsUpdating {

    var insetBottom: CGFloat = 0.0
    
    /// 列表视图
    private lazy var listView: TodoTaskSearchResultListView = {
        let listView = TodoTaskSearchResultListView(frame: view.bounds, style: .insetGrouped)
        listView.detailOption = .allExceptCompletionDate
        listView.keyboardDismissMode = .onDrag
        listView.isKeyboardAdjusterEnabled = true
        listView.shouldHideGroupHeader = true
        listView.delegate = self
        return listView
    }()
    
    private let viewModel = TodoTaskSearchViewModel()
    
    private let taskController = TodoTaskController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listView)
        listView.placeholderProvider = viewModel.placeholderProvider
        listView.keyboardAdjusterInsetBottom = insetBottom
        
        viewModel.onResultsChanged = { [weak self] in
            self?.searchResultsChanged()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func searchResultsChanged() {
        DispatchQueue.main.async {
            self.listView.searchText = self.viewModel.searchText
            self.listView.groups = self.viewModel.groups
            self.listView.reloadData()
        }
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.updateSearchResults(with: searchController.searchBar.text)
    }
    
    // MARK: - TodoTaskListViewDelegate
    func todoTaskListView(_ listView: TodoTaskListView, didSelectTask task: TodoTask) {
        taskController.editTask(task)
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, didClickCheckboxForTask task: TodoTask) {
        taskController.clickCheckbox(for: task, in: listView)
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, leadingSwipeActionsConfigurationForTask task: TodoTask, at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return taskController.leadingSwipeActionsConfiguration(for: task,
                                                                  in: listView,
                                                                  at: indexPath)
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, trailingSwipeActionsConfigurationForTask task: TodoTask, at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return taskController.trailingSwipeActionsConfiguration(for: task,
                                                                   in: listView,
                                                                   at: indexPath)
    }
}

