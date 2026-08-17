//
//  CalendarMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/22.
//

import Foundation
import UIKit

protocol CalendarTitleViewProvider: AnyObject {
    
    var titleView: UIView? { get }
}

class CalendarMainViewController: TPContainerViewController,
                                  TPSidebarContent {
 
    var sidebarController: SidebarController?
    
    var mode: CalendarMode {
        get {
            return modeBarButtonItem.mode
        }
        
        set {
            modeBarButtonItem.mode = newValue
        }
    }
    
    private lazy var moreBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: resGetImage("ellipsis_24"),
                                   style: .done,
                                   target: self,
                                   action: #selector(clickMore))
        return item
    }()
    
    private lazy var modeBarButtonItem: CalendarModeBarButtonItem = {
        let item = CalendarModeBarButtonItem()
        item.didSelectMode = { [weak self] mode in
            self?.selectMode(mode)
        }
        
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
        
        navigationItem.rightBarButtonItems = [moreBarButtonItem,
                                              modeBarButtonItem]
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
        switch mode {
        case .list:
            contentViewController = CalendarListViewController()
        case .day:
            contentViewController = CalendarDayViewController()
        case .week:
            contentViewController = CalendarWeekViewController()
        case .month:
            contentViewController = CalendarMonthViewController()
        case .quarter:
            contentViewController = CalendarQuarterViewController()
        case .year:
            contentViewController = CalendarYearViewController()
        }

        setContentViewController(contentViewController)
        
        /// 设置titleView
        var titleView: UIView?
        if let provider = contentViewController as? CalendarTitleViewProvider {
            titleView = provider.titleView
        }
        
        navigationItem.titleView = titleView
    }
    
    private func selectMode(_ mode: CalendarMode) {
        guard self.mode != mode else {
            return
        }
        
        self.mode = mode
        updateContentViewController()
        CalendarState.shared.mode = mode
    }
    
    @objc private func clickMore() {
        TPImpactFeedback.impactWithSoftStyle()
        CalendarPresenter.showMoreViewController(mode: mode) { newMode in
            self.selectMode(newMode)
        }
    }
    
}

