//
//  RepeatAfterCompletionSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/20.
//

import Foundation

class RepeatAfterCompletionSectionController: TPTableItemSectionController {
    
    var frequencyDidChange: ((RepeatFrequency) -> Void)?
    
    var intervalDidChange: ((Int) -> Void)?
    
    var frequency: RepeatFrequency = .daily
    
    var interval: Int = 1

    /// 频率
    lazy var frequencyCellItem: TPFullSizeSegmentedMenuTableCellItem = {
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.cornerRadius = kInsetGroupedSegmentedMenuCornerRadius
        cellItem.menuItems = frequencyMenuItems
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
    
    lazy var intervalCellItem: TPCountPickerTableCellItem = { [weak self] in
        let cellItem = TPCountPickerTableCellItem()
        cellItem.updater = {
            self?.updateIntervalCellItem()
        }
        
        cellItem.didPickCount = { count in
            self?.didSelectInterval(count)
        }

        return cellItem
    }()
    
    private let frequencies: [RepeatFrequency] = [.daily,
                                                  .weekly,
                                                  .monthly,
                                                  .yearly]

    
    private var frequencyMenuItems: [TPSegmentedMenuItem] {
        var menuItems = [TPSegmentedMenuItem]()
        for frequency in frequencies {
            let menuItem = TPSegmentedMenuItem()
            menuItem.tag = frequency.rawValue
            menuItem.identifier = frequency.identifier
            menuItem.title = frequency.localizedUnit
            menuItems.append(menuItem)
        }
        
        return menuItems
    }
    
    override init() {
        super.init()
        self.headerItem.height = 10.0
        self.footerItem.height = 0.0
        self.cellItems = [frequencyCellItem, intervalCellItem]
    }
    
    // MARK: - Updater
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
    
    func didSelectFrequency(_ frequency: RepeatFrequency) {
        self.frequency = frequency
        self.adapter?.reloadCell(forItem: intervalCellItem, with: .none)
        self.frequencyDidChange?(frequency)
    }
    
    func didSelectInterval(_ interval: Int) {
        self.interval = interval
        self.intervalDidChange?(interval)
    }
    
}
