//
//  MyDayMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/27.
//

import Foundation
import UIKit

class MyDayMainViewController: TPViewController, TFSidebarContent {
 
    var sidebarController: SidebarController?

    /// 内容视图
    private let contentView = UIView()
    
    private lazy var weekView: TPCalendarScrollableWeekView = {
        let view = TPCalendarScrollableWeekView(frame: .zero)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("2025 Feb")
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
        
        view.addSubview(contentView)
        contentView.addSubview(weekView)
        weekView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contentView.frame = view.bounds
        let layoutFrame = contentView.safeLayoutFrame()
        weekView.width = layoutFrame.width
        weekView.height = 80.0
        weekView.top = layoutFrame.minY
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
}
