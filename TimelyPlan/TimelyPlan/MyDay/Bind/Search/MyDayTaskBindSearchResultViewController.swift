//
//  MyDayTaskBindSearchResultViewController.swift
//  iTimeFlow
//
//  Created by caojun on 2023/10/30.
//

import Foundation
import UIKit

class MyDayTaskBindSearchResultViewController: TPTableSectionsViewController,
                                               UISearchResultsUpdating {
    
    lazy var todoResultSectionController: MyDayTodoBindSearchResultSectionController = {
        let sectionController = MyDayTodoBindSearchResultSectionController()
        return sectionController
    }()
 
    lazy var habitResultSectionController: MyDayHabitBindSearchResultSectionController = {
        let sectionController = MyDayHabitBindSearchResultSectionController()
        return sectionController
    }()
    
    lazy var focusResultSectionController: MyDayFocusBindSearchResultSectionController = {
        let sectionController = MyDayFocusBindSearchResultSectionController()
        return sectionController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let provider = TPDefaultPlaceholderProvider()
        provider.emptyImage = resGetImage("placeholder_noSearchResult_80")
        wrapperView.placeholderProvider = provider
        wrapperView.shouldShowPlaceholder = { [weak self] in
            guard let self = self else { return false }
            return !self.adapter.hasItem
        }
    
        wrapperView.isKeyboardAdjusterEnabled = true
        wrapperView.keyboardDismissMode = .onDrag
        sectionControllers = [todoResultSectionController,
                              habitResultSectionController,
                              focusResultSectionController]
        reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        guard let sectionControllers = sectionControllers as? [UISearchResultsUpdating] else {
            return
        }
        
        for sectionController in sectionControllers {
            sectionController.updateSearchResults(for: searchController)
        }
    }
}

