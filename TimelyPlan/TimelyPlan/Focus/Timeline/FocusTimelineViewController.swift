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

class FocusTimelineViewController: TPContainerViewController {
    
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
}

