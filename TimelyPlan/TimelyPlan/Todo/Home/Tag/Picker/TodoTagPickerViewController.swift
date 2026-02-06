//
//  TodoTagPickerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/15.
//

import Foundation

class TodoTagPickerViewController: TPContainerViewController,
                                    UISearchControllerDelegate,
                                    TodoTagSearchResultsViewControllerDelegate {
    
    /// 选中标签回调
    var didPickTags: ((Set<TodoTag>?) -> Void)?
    
    /// 标签搜索控制器
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        let searchBar = searchController.searchBar
        searchBar.placeholder = resGetString("Search Tag")
        searchBar.tintColor = resGetColor(.title)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.delegate = self
        return searchController
    }()
    
    /// 标签选择视图控制器
    lazy var selectViewController: TodoTagSelectViewController = {
        let vc = TodoTagSelectViewController(selection: selection)
        vc.didClickDone = { [weak self] in
            self?.clickDone()
        }
        
        return vc
    }()
    
    private let selection: TPMultipleItemSelection<TodoTag>
    
    init(selectedTags: Set<TodoTag>? = nil) {
        self.selection = TPMultipleItemSelection<TodoTag>(items: Array(selectedTags ?? []))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Tags")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.navigationItem.rightBarButtonItem = addBarButtonItem
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.preferredContentSize = .Popover.extraLarge
        self.setContentViewController(selectViewController, withAnimationStyle: .none)
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override func clickDone() {
        dismiss(animated: true, completion: nil)
        
        let selectedTags = selection.selectedItems
        if selectedTags.count > 0 {
            didPickTags?(selectedTags)
        } else {
            didPickTags?(nil)
        }
    }
    
    override func clickAdd() {
        let tagController = TodoTagController()
        tagController.createTag()
    }
    
    // MARK: - UISearchControllerDelegate
    func willPresentSearchController(_ searchController: UISearchController) {
        let resultVC = TodoTagSearchResultsViewController(selection: selection)
        resultVC.delegate = self
        searchController.searchResultsUpdater = resultVC
        setContentViewController(resultVC, withAnimationStyle: .none)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        setContentViewController(selectViewController, withAnimationStyle: .none)
    }
    
    // MARK: - TodoTagSearchResultsViewControllerDelegate
    func todoTagSearchResultsViewController(_ vc: TodoTagSearchResultsViewController, createTagWithName name: String, color: UIColor) {
        searchController.isActive = false
        
        /// 创建标签
        let tagController = TodoTagController()
        tagController.createTag(withName: name, color: color)
    }
}
