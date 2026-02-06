//
//  FocusTimerSearchResultBaseViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/5.
//

import Foundation

class FocusTimerSearchResultViewController: TPCollectionSectionsViewController,
                                            TPCollectionSectionControllerDelegate,
                                            UISearchResultsUpdating {
    
    var didSelectTimer: ((FocusTimer) -> Void)?
    
    var selectedTimer: FocusTimer?

    /// 条目宽度
    var preferredItemWidth: CGFloat {
        get {
            return resultSectionController.layout.preferredItemWidth
        }
        
        set {
            resultSectionController.layout.preferredItemWidth = newValue
        }
    }
    
    lazy var resultSectionController: FocusTimerSearchResultSectionController = {
        let sectionController = FocusTimerSearchResultSectionController()
        sectionController.delegate = self
        return sectionController
    }()
    
    /// 占位视图
    lazy var placeholderView: TPDefaultPlaceholderView = {
        let view = TPDefaultPlaceholderView()
        view.isBorderHidden = true
        view.image = resGetImage("placeholder_noSearchResult_80")
        return view
    }()
    
    deinit {
        self.collectionView.removeKeyboardNotification()
    }
    
    init(timer: FocusTimer? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.selectedTimer = timer
        self.collectionView.keyboardAutoAdjustContentInset = true
        self.collectionView.addKeyboardNotification()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.placeholderView = self.placeholderView
        self.collectionView.keyboardDismissMode = .interactive
        self.sectionControllers = [resultSectionController]
        self.adapter.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        resultSectionController.updateSearchResults(for: searchController)
    }
    
    func updateSearchResults(with searchText: String?) {
        resultSectionController.updateSearchResults(with: searchText)
    }
    
    // MARK: - TPCollectionSectionControllerDelegate
    func collectionSectionController(_ sectionController: TPCollectionBaseSectionController, didSelectItemAt index: Int) {
        if let timer = sectionController.item(at: index) as? FocusTimer {
            didSelectTimer?(timer)
        }
    }
    
    func collectionSectionController(_ sectionController: TPCollectionBaseSectionController, shouldShowCheckmarkForItemAt index: Int) -> Bool {
        guard let timer = sectionController.item(at: index) as? FocusTimer else {
            return false
        }
        
        return selectedTimer === timer
    }
}
