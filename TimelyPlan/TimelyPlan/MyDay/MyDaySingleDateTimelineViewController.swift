//
//  MyDaySingleDateTimelineViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

/// 单日期时间线视图控制器
class MyDaySingleDateTimelineViewController: MyDayTimelinePageViewController {
    
    /// 展示的日期
    private let date: Date
    
    /// 关闭按钮
    private lazy var closeButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .close,
                                   target: self,
                                   action: #selector(clickClose))
        return item
    }()
    
    init(date: Date) {
        self.date = date.startOfDay()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = closeButtonItem
        navigationItem.title = date.yearMonthDayWeekdaySymbolString(style: .short,
                                                                    omitYear: false)
        
        /// 单日期展示，不允许左右滑动切换日期
        pageView.allowsDateSwitchByPaging = false
        pageView.setVisibleDate(date, animated: false)
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    // MARK: - Event Response
    
    @objc private func clickClose() {
        TPImpactFeedback.impactWithSoftStyle()
        dismiss(animated: true, completion: nil)
    }
}
