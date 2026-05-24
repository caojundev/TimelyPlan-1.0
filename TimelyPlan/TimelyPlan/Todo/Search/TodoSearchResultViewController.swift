//
//  TodoSearchResultViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/24.
//

import Foundation
import UIKit

class TodoSearchResultViewController: TPViewController,
                                      UISearchResultsUpdating {

    /// 列表视图
    private lazy var listView: TodoTaskSearchResultListView = {
        let listView = TodoTaskSearchResultListView(frame: view.bounds, style: .insetGrouped)
        listView.detailOption = .allExceptCompletionDate
        listView.keyboardDismissMode = .onDrag
        listView.isKeyboardAdjusterEnabled = true
//        listView.delegate = self
        return listView
    }()
    
    private let viewModel = TodoTaskSearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listView.placeholderProvider = viewModel.placeholderProvider
        view.addSubview(listView)
        listView.reloadData()
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
            self.listView.performUpdate()
        }
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.updateSearchResults(with: searchController.searchBar.text)
    }
}

