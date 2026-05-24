//
//  TodoSearachMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/24.
//

import Foundation
import UIKit

class TodoSearchMainViewController: TPContainerViewController,
                                     UISearchControllerDelegate {
    
    /// 搜索控制器
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        let searchBar = searchController.searchBar
        searchBar.placeholder = resGetString("Search Task")
        searchBar.tintColor = Color(light: 0x1F212C, dark: 0xD1DAFF)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.delegate = self
        return searchController
    }()
 

    /// 搜索历史视图控制器
    lazy var historyViewController: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .random
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Search")
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        setContentViewController(historyViewController, withAnimationStyle: .none)
    }

    // MARK: - UISearchControllerDelegate
    func willPresentSearchController(_ searchController: UISearchController) {
        let resultVC = TodoSearchResultViewController()
        searchController.searchResultsUpdater = resultVC
        self.setContentViewController(resultVC, withAnimationStyle: .none)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        setContentViewController(historyViewController, withAnimationStyle: .none)
    }
    
}
