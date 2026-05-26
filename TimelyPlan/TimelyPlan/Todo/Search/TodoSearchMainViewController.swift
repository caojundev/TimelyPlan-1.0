//
//  TodoSearachMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/24.
//

import Foundation
import UIKit

class TodoSearchMainViewController: TPContainerViewController,
                                    UISearchBarDelegate,
                                     UISearchControllerDelegate {
    
    /// 搜索控制器
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.automaticallyShowsCancelButton = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.delegate = self
        
        let searchBar = searchController.searchBar
        searchBar.placeholder = resGetString("Search Task")
        searchBar.tintColor = Color(light: 0x1F212C, dark: 0xD1DAFF)
        searchBar.delegate = self
        return searchController
    }()
 
    /// 历史视图控制器
    lazy var historyViewController: TodoSearchHistoryViewController = {
        let vc = TodoSearchHistoryViewController(style: .insetGrouped)
        vc.didSelectHistory = { [weak self] history in
            self?.selectHistory(history)
        }
        
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Search")
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        updateContentViewController()
    }
    
    override func handleFirstAppearance() {
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    private func selectHistory(_ history: String) {
        searchController.searchBar.text = history
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = true
        updateContentViewController(with: history)
        searchController.searchResultsUpdater?.updateSearchResults(for: searchController)
    }
    
    private func updateContentViewController(with searchText: String? = nil) {
        let text = searchText?.whitespacesAndNewlinesTrimmedString
        if let text = text, text.count > 0 {
            if contentViewController == historyViewController {
                let resultViewController = TodoSearchResultViewController()
                resultViewController.insetBottom = historyViewController.insetBottom
                searchController.searchResultsUpdater = resultViewController
                setContentViewController(resultViewController, withAnimationStyle: .none)
            }
        } else {
            setContentViewController(historyViewController, withAnimationStyle: .none)
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateContentViewController(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        historyViewController.searchBarSearchButtonClicked(searchBar)
    }
    
    // MARK: - UISearchControllerDelegate
    func willDismissSearchController(_ searchController: UISearchController) {
        updateContentViewController(with: nil)
    }
}
