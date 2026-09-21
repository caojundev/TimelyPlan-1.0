//
//  CountdownMilestonePickerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/20.
//

import Foundation
import UIKit

/// 里程碑选择视图控制器（选择时间单位与间隔数值）
class CountdownMilestonePickerViewController: TPTableSectionsViewController {
    
    /// 可选的里程碑单位
    static let permittedUnits: [TimeUnit] = [.day, .week, .month, .year]
    
    /// 编辑中的里程碑
    var milestone: CountdownMilestone = CountdownMilestone(interval: 1, unit: .day)
    
    /// 结束选择回调
    var didPickMilestone: ((CountdownMilestone) -> Void)?
    
    convenience init(milestone: CountdownMilestone) {
        self.init(style: .grouped)
        self.milestone = milestone
    }
    
    lazy var milestoneSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 12.0
        sectionController.footerItem.height = 12.0
        return sectionController
    }()
    
    /// 里程碑单位
    lazy var unitCellItem: TPFullSizeSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.cornerRadius = AppLayout.Cell.segmentedMenuCornerRadius
        cellItem.menuItems = TPSegmentedMenuItem.items(with: CountdownMilestonePickerViewController.permittedUnits)
        cellItem.contentPadding = UIEdgeInsets(horizontal: 8.0)
        cellItem.updater = {
            self?.updateUnitCellItem()
        }
        
        cellItem.didSelectMenuItem = { menuItem in
            let unit: TimeUnit? = menuItem.actionType()
            if let unit = unit {
                self?.selectUnit(unit)
            }
        }
        
        return cellItem
    }()
    
    /// 里程碑间隔
    lazy var intervalCellItem: TPCountPickerTableCellItem = { [weak self] in
        let cellItem = TPCountPickerTableCellItem()
        cellItem.updater = {
            self?.updateIntervalCellItem()
        }
        
        cellItem.didPickCount = { count in
            self?.selectInterval(count)
        }
        
        return cellItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionsBarHeight = 75.0
        setupActionsBar(actions: [cancelAction, doneAction])
        milestoneSectionController.cellItems = [unitCellItem, intervalCellItem]
        sectionControllers = [milestoneSectionController]
        adapter.cellStyle.backgroundColor = .secondarySystemBackground
        adapter.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updatePopoverContentSize()
    }
    
    override var popoverContentSize: CGSize {
        let contentHeight = milestoneSectionController.headerItem.height
            + milestoneSectionController.footerItem.height
            + actionsBarHeight
            + unitCellItem.height
            + intervalCellItem.height
        return CGSize(width: AppLayout.Popover.preferredContentWidth, height: contentHeight)
    }
    
    override var themeBackgroundColor: UIColor? {
        return .secondarySystemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .secondarySystemBackground
    }
    
    override func clickDone() {
        didPickMilestone?(milestone)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Event Response
    /// 选择时间单位
    func selectUnit(_ unit: TimeUnit) {
        guard milestone.unit != unit else {
            return
        }
        
        milestone.unit = unit
        adapter.reloadCell(forItem: intervalCellItem, with: .none)
    }
    
    /// 选择间隔数值
    func selectInterval(_ interval: Int) {
        milestone.interval = interval
    }
    
    // MARK: - Update
    /// 更新单位单元格
    private func updateUnitCellItem() {
        unitCellItem.selectedMenuTag = milestone.unit?.rawValue ?? TimeUnit.day.rawValue
    }
    
    /// 更新间隔单元格
    private func updateIntervalCellItem() {
        intervalCellItem.leadingTextForCount = { _ in
            return resGetString("Every")
        }
        
        intervalCellItem.tailingTextForCount = { [weak self] count in
            return self?.milestone.unit?.localizedUnit(for: count)
        }
        
        intervalCellItem.minimumCount = 1
        intervalCellItem.maximumCount = 100
        intervalCellItem.count = milestone.interval ?? 1
    }
}
