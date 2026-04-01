//
//  TodoParentListSearchResultsViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/9.
//

import Foundation

class TodoParentListSearchResultsViewController: TPTableSectionsViewController,
                                                 UISearchResultsUpdating {

    /// 选中列表回调
    var didSelectList: ((TodoList?) -> Void)? {
        didSet {
            resultsSectionController.didSelectList = didSelectList
        }
    }
    
    private var resultsSectionController = TodoParentListSearchResultSectionController()
    
    /// 占位视图
    lazy var placeholderView: TPDefaultPlaceholderView = {
        let view = TPDefaultPlaceholderView()
        view.isBorderHidden = true
        view.image = resGetImage("placeholder_noSearchResult_80")
        return view
    }()
    
    init(selectedList: TodoList?,
         disabledLists: [TodoList]?,
         topLists: [TodoList]?,
         allowMaxDepth: Int) {
        super.init(style: .insetGrouped)
        resultsSectionController.selectedList = selectedList
        resultsSectionController.disabledLists = disabledLists
        resultsSectionController.topLists = topLists
        resultsSectionController.allowMaxDepth = allowMaxDepth
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.placeholderView = self.placeholderView
        self.sectionControllers = [resultsSectionController]
        self.adapter.reloadData()
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        resultsSectionController.updateSearchResults(for: searchController)
    }
}
