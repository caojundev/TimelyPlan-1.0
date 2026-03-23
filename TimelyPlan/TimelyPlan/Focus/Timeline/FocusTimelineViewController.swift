//
//  FocusTimelineViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/7.
//

import Foundation
import UIKit

protocol FocusTimelineTitleViewProvider: AnyObject {
    
    /// 标题视图
    var titleView: UIView? { get }
}

class FocusTimelineViewController: TPContainerViewController,
                                   FocusSessionProcessorDelegate {
    
    private lazy var dayViewController: FocusTimelineDayViewController = {
        let vc = FocusTimelineDayViewController()
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContentViewController(dayViewController)
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        navigationItem.rightBarButtonItem = addBarButtonItem
        navigationItem.titleView = dayViewController.titleView
        
        focus.addUpdater(self, for: [.session])
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickAdd() {
        TPImpactFeedback.impactWithSoftStyle()
        FocusPresenter.addRecordManually()
    }
    
    // MARK: - FocusSessionProcessorDelegate
    func didAddFocusSessions(_ sessions: [FocusSession]) {
        var shouldReload: Bool = false
        for session in sessions {
            if shouldReloadDay(for: session) {
                shouldReload = true
                break
            }
        }
        
        if shouldReload {
            dayViewController.reloadData()
        }
    }
    
    func didUpdateFocusSession(_ session: FocusSession) {
        if shouldReloadDay(for: session) {
            dayViewController.reloadData()
        }
    }
    
    func didDeleteFocusSession(_ session: FocusSession) {
        let date = session.recordTimeline.startDate
        if date.isInSameDayAs(dayViewController.date) {
            dayViewController.reloadData()
        }
    }
    
    private func shouldReloadDay(for session: FocusSession) -> Bool {
        guard let sessionDate = session.startDate else {
            return false
        }

        return sessionDate.isInSameDayAs(dayViewController.date)
    }
}

