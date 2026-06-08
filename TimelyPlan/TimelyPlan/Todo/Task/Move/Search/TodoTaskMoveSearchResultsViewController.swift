//
//  TodoTaskMoveSearchResultsViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/8.
//

import Foundation

class TodoTaskMoveSearchResultsViewController: TPTableSectionsViewController,
                                                  UISearchResultsUpdating {
    
    let resultsSectionController: TodoTaskMoveSearchResultsSectionController
    
    let placeholderProvider = TPDefaultPlaceholderProvider()
    
    init(viewModel: TodoTaskSectionViewModel) {
        self.resultsSectionController = TodoTaskMoveSearchResultsSectionController(viewModel: viewModel)
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeholderProvider.emptyImage = resGetImage("placeholder_noSearchResult_80")
        wrapperView.placeholderProvider = placeholderProvider
        wrapperView.isKeyboardAdjusterEnabled = true
        tableView.separatorStyle = .none
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        sectionControllers = [resultsSectionController]
        reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        resultsSectionController.updateSearchResults(for: searchController)
    }
}
