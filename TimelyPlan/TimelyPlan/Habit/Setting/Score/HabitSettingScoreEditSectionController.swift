//
//  HabitSettingScoreEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/19.
//

import Foundation


class HabitSettingScoreEditSectionController: TPTableItemSectionController {
    
    enum ScoreType: CaseIterable {
        case completed
        case skipped
        case failed
    }
    
    var completedScore: Int = 0
    
    var skippedScore: Int = 0
    
    var failedScore: Int = 0
    
    private let cellHeight = 60.0
    
    private let valueFont = UIFont.boldSystemFont(ofSize: 20.0)
    
    lazy var completedScoreCellItem: TPDefaultInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPDefaultInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.height = cellHeight
        cellItem.title = resGetString("Completed Score")
        cellItem.valueConfig.valueFont = valueFont
        cellItem.updater = {
            guard let self = self else { return }
            self.completedScoreCellItem.valueConfig = .valueText("\(self.completedScore)", textColor: .primary)
        }
        
        cellItem.didSelectHandler = {
            self?.editScore(type: .completed)
        }
        
        return cellItem
    }()
    
    lazy var skippedScoreCellItem: TPDefaultInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPDefaultInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.height = cellHeight
        cellItem.title = resGetString("Skipped Score")
        cellItem.valueConfig.valueFont = valueFont
        cellItem.updater = {
            guard let self = self else { return }
            self.skippedScoreCellItem.valueConfig = .valueText("\(self.skippedScore)", textColor: .primary)
        }
        
        cellItem.didSelectHandler = {
            self?.editScore(type: .skipped)
        }
        
        return cellItem
    }()
    
    lazy var failedScoreCellItem: TPDefaultInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPDefaultInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.height = cellHeight
        cellItem.title = resGetString("Failed Score")
        cellItem.valueConfig.valueFont = valueFont
        cellItem.updater = {
            guard let self = self else { return }
            self.failedScoreCellItem.valueConfig = .valueText("\(self.failedScore)", textColor: .primary)
        }
        
        cellItem.didSelectHandler = {
            self?.editScore(type: .failed)
        }
        
        return cellItem
    }()
    
    override init() {
        super.init()
        self.headerItem.height = 15.0
        self.cellItems = [completedScoreCellItem,
                          skippedScoreCellItem,
                          failedScoreCellItem]
    }

    /// 更新所有数值
    func updateAllValues() {
        for scoreType in ScoreType.allCases {
            updateValue(for: scoreType)
        }
    }

    private func editScore(type: ScoreType) {
        guard let cell = cell(for: type) else {
            return
        }
        
        let vc = TPSliderViewController()
        vc.value = Float(score(for: type))
        vc.didChangeValue = { value in
            self.scoreValueChanged(Int(value), type: type)
        }

        popoverShow(vc, from: cell)
    }
    
    private func scoreValueChanged(_ value: Int, type: ScoreType) {
        setScore(value, for: type)
        updateValue(for: type)
    }
    
    @discardableResult
    private func setScore(_ value: Int, for scoreType: ScoreType) -> Bool {
        var success: Bool = false
        switch scoreType {
        case .completed:
            if completedScore != value {
                completedScore = value
                success = true
            }
            
        case .skipped:
            if skippedScore != value {
                skippedScore = value
                success = true
            }
            
        case .failed:
            if failedScore != value {
                failedScore = value
                success = true
            }
        }
        
        return success
    }
    
    private func score(for scoreType: ScoreType) -> Int {
        switch scoreType {
        case .completed:
            return completedScore
        case .skipped:
            return skippedScore
        case .failed:
            return failedScore
        }
    }
    
    private func updateValue(for scoreType: ScoreType) {
        let cellItem = cellItem(for: scoreType)
        cellItem.updater?()
        
        let cell = adapter?.cellForItem(cellItem) as? TPDefaultInfoTextValueTableCell
        cell?.updateValueConfig()
    }

    private func cellItem(for scoreType: ScoreType) -> TPBaseTableCellItem {
        switch scoreType {
        case .completed:
            return completedScoreCellItem
        case .skipped:
            return skippedScoreCellItem
        case .failed:
            return failedScoreCellItem
        }
    }

    private func cell(for scoreType: ScoreType) -> TPDefaultInfoTextValueTableCell? {
        let cellItem = cellItem(for: scoreType)
        let cell = adapter?.cellForItem(cellItem) as? TPDefaultInfoTextValueTableCell
        return cell
    }
    
}
