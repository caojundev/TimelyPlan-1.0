//
//  FocusTimerSelectViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/30.
//

import Foundation

class FocusTimerSelectViewController: TPCollectionSectionsViewController,
                                      TPCollectionSectionControllerDelegate {
    
    var selectedTimer: FocusTimerRepresentable?
    
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
    
    /// 用户计时器选择
    lazy var userTimerSelectSectionController: FocusUserTimerSelectSectionController = {
        let sectionController = FocusUserTimerSelectSectionController()
        sectionController.showHeader = true
        sectionController.headerHeight = 40.0
        sectionController.delegate = self
        return sectionController
    }()
    
    init(timer: FocusTimerRepresentable? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.selectedTimer = timer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.placeholderView = placeholderView
        self.sectionControllers = [userTimerSelectSectionController]
        self.adapter.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - TPCollectionSectionControllerDelegate
    func collectionSectionController(_ sectionController: TPCollectionBaseSectionController, didSelectItemAt index: Int) {
        guard let timer = sectionController.item(at: index) as? FocusTimerRepresentable else {
            return
        }
        
        selectedTimer = timer
        adapter.updateCheckmarks()
        didSelectTimer?(timer)
    }
    
    func collectionSectionController(_ sectionController: TPCollectionBaseSectionController, shouldShowCheckmarkForItemAt index: Int) -> Bool {
        guard let selectedTimer = selectedTimer,
              let timer = sectionController.item(at: index) as? FocusTimerRepresentable else {
            return false
        }
        
        return timer.isSame(as: selectedTimer)
    }
}
