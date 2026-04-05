//
//  TodoTagSearchResultsViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/9.
//

import Foundation
import UIKit

protocol TodoTagSearchResultsViewControllerDelegate: AnyObject {
    /// 创建新标签
    func todoTagSearchResultsViewController(_ vc: TodoTagSearchResultsViewController,
                                            createTagWithName name: String,
                                            color: UIColor)
}

class TodoTagSearchResultsViewController: TPTableSectionsViewController,
                                            UISearchResultsUpdating {
    
    weak var delegate: TodoTagSearchResultsViewControllerDelegate?
    
    private let resultsSectionController: TodoTagSelectSectionController
  
    private let viewModel = TodoTagSearchResultViewModel()
    
    /// 占位视图
    private lazy var placeholderView: TodoTagSearchResultsPlaceholderView = {
        let placeholderView = TodoTagSearchResultsPlaceholderView()
        placeholderView.didClickCreate = { [weak self] name, color in
            self?.createTag(name: name, color: color)
        }

        return placeholderView
    }()

    let selection: TPMultipleItemSelection<TodoTag>
    
    init(selection: TPMultipleItemSelection<TodoTag>) {
        self.selection = selection
        self.resultsSectionController = TodoTagSelectSectionController(selection: selection)
        super.init(style: .insetGrouped)
        self.viewModel.didLoadTags = { [weak self] in
            self?.didChangeTags()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.placeholderView = placeholderView
        self.sectionControllers = [resultsSectionController]
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.adapter.reloadData()
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func createTag(name: String?, color: UIColor) {
        guard let name = name, name.count > 0 else {
            return
        }
        
        delegate?.todoTagSearchResultsViewController(self,
                                                     createTagWithName: name,
                                                     color: color)
    }
    
    private func didChangeTags() {
        self.resultsSectionController.tags = self.viewModel.tags
        self.adapter.performUpdate(completion: nil)
        self.updatePlaceholder()
    }
    
    private func updatePlaceholder() {
        let tagsCount = self.viewModel.tags?.count ?? 0
        if tagsCount == 0 {
            self.placeholderView.tagName = self.viewModel.searchText
        } else {
            self.placeholderView.tagName = nil
        }
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        self.placeholderView.tagName = nil
        
        let searchText = searchController.searchBar.text?.whitespacesAndNewlinesTrimmedString
        self.viewModel.searchTags(contain: searchText)
    }
}
