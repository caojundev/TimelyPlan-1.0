//
//  TodoListMoveViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/15.
//

import Foundation

class TodoListMoveViewController: TPContainerViewController,
                                  UISearchControllerDelegate  {
    
    /// 选中列表回调
    var didSelectList: ((TodoListRepresentable?) -> Void)?

    /// 当前列表
    let list: TodoListRepresentable?

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

    let selectViewController: TodoListSelectViewController
    
    init(list: TodoListRepresentable?) {
        self.list = list
        self.selectViewController = TodoListSelectViewController(list: list)
        super.init(nibName: nil, bundle: nil)
        self.selectViewController.didSelectList = { [weak self] list in
            self?.selectList(list)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Move To")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.setContentViewController(selectViewController, withAnimationStyle: .none)
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    /// 选中列表
    private func selectList(_ list: TodoListRepresentable?) {
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
        let resultVC = TodoListSearchResultsViewController(list: list as? TodoList)
        resultVC.didSelectList = { list in
            self.selectList(list)
        }

        searchController.searchResultsUpdater = resultVC
        setContentViewController(resultVC, withAnimationStyle: .none)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        setContentViewController(selectViewController, withAnimationStyle: .none)
    }
}
