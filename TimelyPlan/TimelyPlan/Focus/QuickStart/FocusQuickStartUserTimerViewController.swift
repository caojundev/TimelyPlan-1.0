//
//  FocusQuickStartUserTimerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/26.
//

import Foundation
import UIKit

class FocusQuickStartUserTimerViewController: TPCollectionSectionsViewController,
                                              TPCollectionSectionControllerDelegate {

    var didSelectTimer: ((FocusTimerRepresentable) -> Void)?
    
    private lazy var placeholderView: TPDefaultPlaceholderView = {
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
        sectionController.delegate = self
        return sectionController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.placeholderView = placeholderView
        self.sectionControllers = [userTimerSelectSectionController]
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
        
        didSelectTimer?(timer)
    }
}
