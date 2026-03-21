//
//  HabitRecordListSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/21.
//

import Foundation

class HabitRecordListSectionController: TPCollectionBaseSectionController,
                                        HabitTaskListInfoCellDelegate {
    
    let date: Date
    
    let dailyItems: [HabitDailyItem]
    
    /// 区块布局对象
    let sectionLayout = TPCollectionSectionLayout()
    
    init(date: Date, dailyItems: [HabitDailyItem]) {
        self.date = date
        self.dailyItems = dailyItems
        super.init()
        self.identifier = date.yearMonthDayString
        self.sectionLayout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.sectionLayout.preferredItemWidth = .greatestFiniteMagnitude
        self.sectionLayout.preferredItemHeight = .greatestFiniteMagnitude
    }
    
    override var items: [ListDiffable]? {
        return self.dailyItems
    }
    
    override func sectionInset() -> UIEdgeInsets {
        return sectionLayout.sectionInset
    }
    
    override func interitemSpacing() -> CGFloat {
        return sectionLayout.interitemSpacing
    }
    
    override func lineSpacing() -> CGFloat {
        return sectionLayout.lineSpacing
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        sectionLayout.collectionViewSize = adapter?.collectionViewSize() ?? .zero
        let constraintCellSize = sectionLayout.constraintCellSize ?? .zero
        return CGSize(width: constraintCellSize.width, height: 80.0)
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return HabitRecordListCell.self
    }
    
    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        guard let cell = cell as? HabitRecordListCell else {
            return
        }
        
        cell.delegate = self
        cell.dailyItem = item(at: index) as? HabitDailyItem
    }
    
    override func didSelectItem(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        guard let dailyItem = item(at: index) as? HabitDailyItem else {
            return
        }
        
        self.editRecord(for: dailyItem)
    }
    
    // MARK: - Header
    override func sizeForHeader() -> CGSize {
        return CGSize(width: .greatestFiniteMagnitude, height: 40.0)
    }
    
    override func classForHeader() -> AnyClass? {
        return TPCollectionHeaderFooterView.self
    }
    
    override func didDequeHeader(_ headerView: UICollectionReusableView) {
        if let headerView = headerView as? TPCollectionHeaderFooterView {
            headerView.padding = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 0, right: 16.0)
            headerView.titleConfig.font = .boldSystemFont(ofSize: 14.0)
            headerView.titleConfig.textColor = resGetColor(.title)
            headerView.title = date.monthDayWeekdaySymbolString
        }
    }
    
    // MARK: - HabitTaskListInfoCellDelegate
    func habitTaskListInfoCell(_ cell: HabitTaskListDefaultInfoCell, didClickMore button: UIButton) {
        guard let cell = cell as? HabitRecordListCell, let dailyItem = cell.dailyItem else {
            return
        }
        
        let menuController = HabitRecordMenuController()
        menuController.didSelectMenuActionType = { type in
            switch type {
            case .editLog:
                self.editRecord(for: dailyItem)
            case .delete:
                self.deleteRecord(for: dailyItem)
            }
        }

        let sourceRect = button.bounds.insetBy(dx: 0.0, dy: -12.0)
        menuController.showMenu(from: button,
                                sourceRect: sourceRect,
                                isCovered: true)
    }
    
    
    // MARK: - Private Methods
    func editRecord(for dailyItem: HabitDailyItem) {
        guard let date = dailyItem.record.date else {
            return
        }
    
        let recordController = HabitRecordController()
        recordController.editLog(for: dailyItem.task,
                                    with: dailyItem.record,
                                    on: date)
    }
    
    func deleteRecord(for dailyItem: HabitDailyItem) {
        guard let date = dailyItem.record.date else {
            return
        }
        
        HabitPresenter.confirmRecordDeletion { confirmed in
            if confirmed {
                habit.resetToday(of: date, for: dailyItem.task)
            }
        }
    }
}
