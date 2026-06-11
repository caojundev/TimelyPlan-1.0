//
//  BaseSettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/11.
//

import Foundation

class BaseSettingViewController: TPTableSectionsViewController {
    
    var defaultCellHeight = 60.0
    
    let normalHeaderHeight = 15.0
    
    let titleHeaderHeight = 50.0
    
    let titleHeaderPadding = UIEdgeInsets(top: 15.0, left: 5.0, bottom: 0.0, right: 5.0)
    
    
    
    var isPushed: Bool = false
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !isPushed {
            navigationItem.leftBarButtonItems = [chevronDownCancelButtonItem]
        }
        
        navigationItem.backButtonDisplayMode = .minimal
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
}
