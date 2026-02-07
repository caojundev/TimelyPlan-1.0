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
        navigationItem.leftBarButtonItems = [chevronDownCancelButtonItem]
        updateContentViewController()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func updateContentViewController() {
        let contentViewController: UIViewController
        contentViewController = dayViewController
        setContentViewController(contentViewController)
        
        /// 设置titleView
        var titleView: UIView?
        if let provider = contentViewController as? FocusTimelineTitleViewProvider {
            titleView = provider.titleView
        }
        
        navigationItem.titleView = titleView
    }
}

