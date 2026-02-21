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
        
        focus.addUpdaterDelegate(self)
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickAdd() {
        FocusPresenter.addRecordManually()
    }
    
    // MARK: - FocusSessionProcessorDelegate
    func didAddFocusSession(_ session: FocusSession, with record: FocusRecord) {
        reloadIfNeeded(with: session)
    }
    
    func didUpdateFocusSession(_ session: FocusSession) {
        reloadIfNeeded(with: session)
    }
    
    func didDeleteFocusSession(with record: FocusRecord) {
        let date = record.timeline.startDate
        if date.isInSameDayAs(dayViewController.date) {
            dayViewController.reloadData()
        }
    }
    
    private func reloadIfNeeded(with session: FocusSession) {
        guard let sessionDate = session.startDate else {
            return
        }

        if sessionDate.isInSameDayAs(dayViewController.date) {
            dayViewController.reloadData()
        }
    }
    
}

