//
//  RepeatFrequencySectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/22.
//

import Foundation

class RepeatFrequencySectionController: TPTableItemSectionController {
    
    var frequencyDidChange: ((RepeatFrequency) -> Void)?
    
    var intervalDidChange: ((Int) -> Void)?
    
    var frequency: RepeatFrequency = .daily
    
    var interval: Int = 1
    
    /// 频率
    lazy var frequencyCellItem: TPFullSizeSegmentedMenuTableCellItem = {
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.cornerRadius = kInsetGroupedSegmentedMenuCornerRadius
        cellItem.menuItems = RepeatFrequency.segmentedMenuItems()
        cellItem.updater = { [weak self] in
            self?.updateFrequencyCellItem()
        }
        
        cellItem.didSelectMenuItem = { [weak self] menuItem in
            let frequency: RepeatFrequency? = menuItem.actionType()
            if let frequency = frequency {
                self?.didSelectFrequency(frequency)
            }
        }
        
        return cellItem
    }()
    
    lazy var intervalCellItem: TPCountPickerTableCellItem = {
        let cellItem = TPCountPickerTableCellItem()
        cellItem.updater = { [weak self] in
            self?.updateIntervalCellItem()
        }
        
        cellItem.leadingTextForCount = { _ in
            return resGetString("Every")
        }
        
        cellItem.didPickCount = { [weak self] count in
            self?.didSelectInterval(count)
        }
        
        return cellItem
    }()

    override init() {
        super.init()
        self.headerItem.height = 10.0
        self.footerItem.height = 0.0
        self.cellItems = [frequencyCellItem, intervalCellItem]
    }

    // MARK: - Update CellItems
    func updateFrequencyCellItem() {
        frequencyCellItem.selectedMenuTag = frequency.rawValue
    }
    
    func updateIntervalCellItem() {
        intervalCellItem.tailingTextForCount = { [weak self] count in
            return self?.frequency.localizedUnit(for: count)
        }
        
        intervalCellItem.minimumCount = 1
        intervalCellItem.maximumCount = 100
        intervalCellItem.count = interval
    }
    
    // MARK: - 编辑
    func didSelectFrequency(_ frequency: RepeatFrequency) {
        self.frequency = frequency
        self.adapter?.performUpdate(with: .fade, completion: nil)
        self.adapter?.reloadCell(forItem: intervalCellItem, with: .none)
        self.frequencyDidChange?(frequency)
    }
    
    func didSelectInterval(_ interval: Int) {
        self.interval = interval
        self.intervalDidChange?(interval)
    }
}
