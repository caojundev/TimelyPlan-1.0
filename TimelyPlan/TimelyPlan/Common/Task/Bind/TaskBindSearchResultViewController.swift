//
//  TaskBindSearchResultViewController.swift
//  iTimeFlow
//
//  Created by caojun on 2023/10/30.
//

import Foundation
import UIKit

class TaskBindSearchResultViewController: UIViewController,
                                          UISearchResultsUpdating {
    
    /// 当前结果对应的搜索文本
    var searchText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: -  UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.whitespacesAndNewlinesTrimmedString
        if self.searchText == searchText {
            return
        }
        
        guard let searchText = searchText, searchText.count > 0 else {
            self.searchText = nil
//            self.taskGroups = nil
//            self.reloadData()
            return
        }

        self.searchText = searchText
        
        /// 执行搜索
//        TaskSearch.searchTasks(containText: searchText) { taskGroups in
//            guard searchText == self.searchText else {
//                return
//            }
//
//            self.taskGroups = taskGroups
//            self.reloadData()
//            self.adapter.performUpdate(with: .top, completion: nil)
//        }
    }
}
