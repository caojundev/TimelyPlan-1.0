//
//  TodoParentListSearchResultsViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/9.
//

import Foundation

class TodoListSearchResultsViewController: TPTableSectionsViewController,
                                                UISearchResultsUpdating {
    
    var didSelectList: ((TodoList?) -> Void)? {
        didSet {
            resultsSectionController.didSelectList = didSelectList
        }
    }
    
    private let resultsSectionController = TodoListSearchResultsSectionController()
    
    /// 占位视图
    lazy var placeholderView: TPDefaultPlaceholderView = {
        let view = TPDefaultPlaceholderView()
        view.isBorderHidden = true
        view.image = resGetImage("placeholder_noSearchResult_80")
        return view
    }()
    
    init(list: TodoList?) {
        super.init(style: .grouped)
        resultsSectionController.selectedList = list
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.keyboardDismissMode = .onDrag
        tableView.placeholderView = placeholderView
        sectionControllers = [resultsSectionController]
        adapter.reloadData()
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        resultsSectionController.updateSearchResults(for: searchController)
    }
}
