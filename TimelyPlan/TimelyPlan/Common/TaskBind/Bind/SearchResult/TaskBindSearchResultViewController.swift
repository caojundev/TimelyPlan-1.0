//
//  TaskBindSearchResultViewController.swift
//  iTimeFlow
//
//  Created by caojun on 2023/10/30.
//

import Foundation
import UIKit

class TaskBindSearchResultViewController: TPCollectionSectionsViewController,
                                          TPCollectionSectionControllerDelegate,
                                            UISearchResultsUpdating {

    var didSelectTask: ((TaskRepresentable) -> Void)?
    
    /// 当前选中任务标识
    private(set) var selectedTaskID: String?
    
    private lazy var placeholderView: TPDefaultPlaceholderView = {
        let view = TPDefaultPlaceholderView()
        view.isBorderHidden = true
        view.titleColor = .placeholderText
        view.image = resGetImage("placeholder_noSearchResult_80")
        return view
    }()
    
    lazy var habitSearchResultSectionController: HabitTaskBindSearchResultSectionController = {
        let sectionController = HabitTaskBindSearchResultSectionController()
        sectionController.delegate = self
        return sectionController
    }()

    deinit {
        self.collectionView.removeKeyboardNotification()
    }
    
    init(selectedTaskID: String?) {
        self.selectedTaskID = selectedTaskID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.placeholderView = placeholderView
        self.collectionView.keyboardAutoAdjustContentInset = true
        self.collectionView.addKeyboardNotification()
        self.collectionView.keyboardDismissMode = .interactive
        self.sectionControllers = [self.habitSearchResultSectionController]
        self.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let sectionControllers = self.sectionControllers as? [UISearchResultsUpdating] else {
            return
        }
        
        for sectionController in sectionControllers {
            sectionController.updateSearchResults(for: searchController)
        }
    }
    
    // MARK: - TPCollectionSectionControllerDelegate
    func collectionSectionController(_ sectionController: TPCollectionBaseSectionController, shouldShowCheckmarkForItemAt index: Int) -> Bool {
        guard let task = sectionController.item(at: index) as? TaskRepresentable else {
            return false
        }
    
        return task.feature.identifier == self.selectedTaskID
    }
    
    func collectionSectionController(_ sectionController: TPCollectionBaseSectionController, didSelectItemAt index: Int) {
        guard let task = sectionController.item(at: index) as? TaskRepresentable else {
            return
        }
        
        didSelectTask?(task)
    }
}

