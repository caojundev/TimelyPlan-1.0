//
//  FocusArchivedViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/6.
//

import Foundation

class FocusArchivedViewController: TPCollectionSectionsViewController,
                                    FocusTimerProcessorDelegate {

    /// 占位视图
    lazy var placeholderView: TPDefaultPlaceholderView = {
        let view = TPDefaultPlaceholderView()
        view.isBorderHidden = true
        view.image = resGetImage("archivedList_80")
        return view
    }()
    
    lazy var sectionController: FocusArchivedTimerSectionController = {
        let sectionController = FocusArchivedTimerSectionController()
        return sectionController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.title = resGetString("Archived")
        self.collectionView.placeholderView = placeholderView
        self.sectionControllers = [sectionController]
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.adapter.reloadData()
        focus.addUpdaterDelegate(self)
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - FocusTimerProcessorDelegate
    func didChangeArchivedState(_ isArchived: Bool, for timer: FocusTimer) {
        self.adapter.performUpdate()
    }
    
    func didDeleteFocusTimer(_ timer: FocusTimer) {
        self.adapter.performUpdate()
    }
}
