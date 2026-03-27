//
//  FocusTimerSelectViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/30.
//

import Foundation

class FocusTimerSelectViewController: TPCollectionSectionsViewController,
                                      TPCollectionSectionControllerDelegate {
    
    var selectedTimerID: String?
    
    var didSelectTimer: ((FocusTimerRepresentable) -> Void)?
    
    /// 占位视图
    lazy var placeholderView: TPDefaultPlaceholderView = {
        let view = TPDefaultPlaceholderView()
        view.isBorderHidden = true
        view.image = resGetImage("focus_placeholder_noTimer_80")
        view.titleColor = .placeholderText
        view.title = resGetString("No Timer")
        return view
    }()
    
    /// 默认计时器选择
    lazy var defaultTimerSelectSectionController: FocusDefaultTimerSelectSectionController = {
        let sectionController = FocusDefaultTimerSelectSectionController()
        sectionController.delegate = self
        return sectionController
    }()
    
    /// 用户计时器选择
    lazy var userTimerSelectSectionController: FocusUserTimerSelectSectionController = {
        let sectionController = FocusUserTimerSelectSectionController()
        sectionController.showHeader = true
        sectionController.headerHeight = 40.0
        sectionController.delegate = self
        return sectionController
    }()
    
    init(selectedTimerID: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.selectedTimerID = selectedTimerID
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.placeholderView = placeholderView
        self.sectionControllers = [defaultTimerSelectSectionController,
                                   userTimerSelectSectionController]
        self.loadData()
    }

    func loadData() {
        focus.fetchActiveTimers { timers in
            self.userTimerSelectSectionController.timers = timers
            self.adapter.reloadData()
        }
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - TPCollectionSectionControllerDelegate
    func collectionSectionController(_ sectionController: TPCollectionBaseSectionController, didSelectItemAt index: Int) {
        guard let timer = sectionController.item(at: index) as? FocusTimerRepresentable else {
            return
        }
        
        self.selectedTimerID = timer.identifier
        adapter.updateCheckmarks()
        didSelectTimer?(timer)
    }
    
    func collectionSectionController(_ sectionController: TPCollectionBaseSectionController, shouldShowCheckmarkForItemAt index: Int) -> Bool {
        guard let selectedTimerID = self.selectedTimerID,
              let timer = sectionController.item(at: index) as? FocusTimerRepresentable else {
            return false
        }
        
        return timer.identifier == selectedTimerID
    }
}
