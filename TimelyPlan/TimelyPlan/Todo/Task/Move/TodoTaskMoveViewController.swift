//
//  TodoTaskMoveViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/5.
//

import Foundation
import UIKit

class TodoTaskMoveViewController: TPContainerViewController,
                                  UISearchControllerDelegate  {
    
    /// 选中板块
    var didSelectSection: ((TodoSectionFeature?) -> Void)?

    /// 当前板块
    let section: TodoSectionFeature?
    
    /// 列表搜索控制器
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        let searchBar = searchController.searchBar
        searchBar.placeholder = resGetString("Search List Or Section")
        searchBar.tintColor = resGetColor(.title)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.delegate = self
        return searchController
    }()
    
    lazy var selectViewController: TodoTaskSectionSelectViewController = {
        let vc = TodoTaskSectionSelectViewController()
        return vc
    }()

    init(section: TodoSectionFeature?) {
        self.section = section
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
        title = resGetString("Move To")
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
//        selectViewController.didSelectList = { [weak self] list in
//            self?.pickList(list)
//        }
//
        setContentViewController(selectViewController, withAnimationStyle: .none)
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    /// 选中板块
    private func pickSection(_ section: TodoSectionFeature?) {
        TPImpactFeedback.impactWithSoftStyle()
        self.didSelectSection?(section)
        if let presentingVC = self.presentingViewController {
            presentingVC.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - UISearchControllerDelegate
    func willPresentSearchController(_ searchController: UISearchController) {
//        let topLists = self.selectViewController.topLists
//        let resultVC = TodoListSearchResultsViewController(selectedList: self.list,
//                                                           disabledLists: self.disabledLists,
//                                                           topLists: topLists,
//                                                           allowMaxDepth: self.allowMaxDepth)
//        resultVC.didSelectList = { list in
//            self.pickList(list)
//        }

        let resultVC = UIViewController()
//        searchController.searchResultsUpdater = resultVC
        setContentViewController(resultVC, withAnimationStyle: .none)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        setContentViewController(selectViewController, withAnimationStyle: .none)
    }
}
