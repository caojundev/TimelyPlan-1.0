//
//  TodoBaseListPickerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/4.
//

import Foundation
import UIKit

class TodoBaseListPickerViewController: TPContainerViewController,
                                        UISearchControllerDelegate  {
    
    /// 选中列表回调
    var didSelectList: ((TodoList?) -> Void)?

    /// 当前列表
    let list: TodoList?
    
    /// 允许的最大深度
    let allowMaxDepth: Int

    /// 父列表
    var disabledLists: [TodoList]? {
        get {
            return selectViewController.disabledLists
        }
        
        set {
            selectViewController.disabledLists = newValue
        }
    }
    
    /// 列表搜索控制器
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        let searchBar = searchController.searchBar
        searchBar.placeholder = resGetString("Search List")
        searchBar.tintColor = resGetColor(.title)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.delegate = self
        return searchController
    }()

    var selectViewController: TodoBaseListSelectViewController!
    
    init(list: TodoList?, allowMaxDepth: Int = .max) {
        self.list = list
        self.allowMaxDepth = allowMaxDepth
        super.init(nibName: nil, bundle: nil)
        self.setupSelectViewController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupSelectViewController() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.selectViewController.didSelectList = { [weak self] list in
            self?.pickList(list)
        }
        
        self.setContentViewController(self.selectViewController, withAnimationStyle: .none)
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    /// 选中列表
    private func pickList(_ list: TodoList?) {
        TPImpactFeedback.impactWithSoftStyle()
        self.didSelectList?(list)
        if let presentingVC = self.presentingViewController {
            presentingVC.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - UISearchControllerDelegate
    func willPresentSearchController(_ searchController: UISearchController) {
        let topLists = self.selectViewController.topLists
        let resultVC = TodoListSearchResultsViewController(selectedList: self.list,
                                                                 disabledLists: self.disabledLists,
                                                                 topLists: topLists,
                                                                 allowMaxDepth: self.allowMaxDepth)
        resultVC.didSelectList = { list in
            self.pickList(list)
        }

        searchController.searchResultsUpdater = resultVC
        setContentViewController(resultVC, withAnimationStyle: .none)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        setContentViewController(selectViewController, withAnimationStyle: .none)
    }
}
