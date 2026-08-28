//
//  GanttTimelineSettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/27.
//

import Foundation
import UIKit

class GanttTimelineSettingViewController: TPTableSectionsViewController {
    
    var didSelectScale: ((GanttTimeScale.Scale) -> Void)?
    
    /// 返回
    lazy var dismissButtonItem: UIBarButtonItem = {
        let image = resGetImage("chevron_right_24")
        let item = UIBarButtonItem(image: image,
                                   style: .plain,
                                   target: self,
                                   action: #selector(clickDismiss))
        return item
    }()
    
    /// 模式
    lazy var modeCellItem: TPFullSizeSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.height = 90.0
        cellItem.contentPadding = UIEdgeInsets(horizontal: 4.0, vertical: 4.0)
        cellItem.minimumButtonWidth = 80.0
        cellItem.imagePosition = .top
        cellItem.segmentedImageConfig.margins = UIEdgeInsets(bottom: 5.0)
        cellItem.segmentedImageConfig.size = .size(6)
        cellItem.segmentedTitleConfig.font = BOLD_SMALL_SYSTEM_FONT
        cellItem.cornerRadius = 12.0
         
        cellItem.menuItems = GanttTimeScale.Scale.segmentedMenuItems()
        cellItem.updater = {
            guard let self = self else { return }
            self.modeCellItem.selectedMenuTag = self.scale.tag
        }
        
        cellItem.didSelectMenuItem = { menuItem in
            let scale: GanttTimeScale.Scale? = menuItem.actionType()
            if let scale = scale {
                self?.selectScale(scale)
            }
        }
        
        return cellItem
    }()
    
    lazy var modeSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 5.0
        sectionController.cellItems = [modeCellItem]
        return sectionController
    }()

    lazy var settingSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 15.0
        sectionController.cellItems = []
        return sectionController
    }()
    
    private(set) var scale: GanttTimeScale.Scale
    
    init(scale: GanttTimeScale.Scale) {
        self.scale = scale
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = dismissButtonItem
        wrapperView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.01))
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        sectionControllers = [modeSectionController, settingSectionController]
        reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func selectScale(_ scale: GanttTimeScale.Scale) {
        guard self.scale != scale else {
            return
        }
        
        self.scale = scale
        didSelectScale?(scale)
        dismiss(animated: true)
    }
    
    // MARK: - Event Response
    @objc private func clickDismiss() {
        TPImpactFeedback.impactWithSoftStyle()
        dismiss(animated: true)
    }

}
