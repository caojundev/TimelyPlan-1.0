//
//  HabitRecordListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/20.
//

import Foundation
import UIKit

class HabitRecordListViewController: StatsContentViewController,
                                     HabitRecordProcessorDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        habit.addUpdater(self, for: [.record])
    }
    
    override func placeholderView() -> UIView? {
        let view = TPDefaultPlaceholderView()
        view.image = resGetImage("habit_record_80")
        view.title = resGetString("No Habit Record")
        view.titleColor = .lightGray
        return view
    }
    
    override func fetchSectionControllers(completion: @escaping ([TPCollectionBaseSectionController]) -> Void) {
        Habit.fetchRecordsGroupedByDay(in: self.dateRange) { results in
            let sectionControllers: [HabitRecordListSectionController]
            if let results = results, results.count > 0 {
                sectionControllers = self.sectionControllers(with: results)
            } else {
                sectionControllers = []
            }

            completion(sectionControllers)
        }
    }
    
    private func sectionControllers(with dayRecords: HabitGroupedByDayRecords) -> [HabitRecordListSectionController] {
        var sectionControllers = [HabitRecordListSectionController]()
        let sortedDayRecords = dayRecords.sorted(by: { $0.key < $1.key })
        for (day, records) in sortedDayRecords {
            guard let date = Date.dateFromDayIntegerKey(day) else {
                continue
            }
            
            let sectionController = HabitRecordListSectionController(date: date,
                                                                     records: records)

            sectionControllers.append(sectionController)
        }

        return sectionControllers
    }
    
    // MARK: - HabitRecordProcessorDelegate
     func didUpdateHabitRecord(_ record: HabitRecord, for task: HabitTask, on date: Date, with change: HabitRecordChange) {
         
     }
    
    /*
    func didAddFocusSessions(_ sessions: [FocusSession]) {
        guard sessions.count == 1, let session = sessions.first else { return }
        guard let date = session.startDate, self.dateRange.contains(date: date) else {
            return
        }
        
        self.reloadData {
            self.adapter.scrollToItem(session, at: .centeredVertically, animated: true) { _ in
                self.adapter.commitFocusAnimation(for: session)
            }
        }
    }
    
    func didUpdateFocusSession(_ session: FocusSession) {
        self.reloadData {
            self.adapter.scrollToItem(session, at: .centeredVertically, animated: true) { _ in
                self.adapter.commitFocusAnimation(for: session)
            }
        }
    }
    
    func didDeleteFocusSession(with record: FocusRecord) {
        self.reloadData()
    }
    */
}


class HabitRecordListSectionController: TPCollectionBaseSectionController {
    
    let date: Date
    
    let records: [HabitRecord]
    
    /// 区块布局对象
    let sectionLayout = TPCollectionSectionLayout()
    
    init(date: Date, records: [HabitRecord]) {
        self.date = date
        self.records = records
        super.init()
        self.identifier = date.yearMonthDayString
        self.sectionLayout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.sectionLayout.preferredItemWidth = .greatestFiniteMagnitude
        self.sectionLayout.preferredItemHeight = .greatestFiniteMagnitude
    }
    
    override var items: [ListDiffable]? {
        return self.records
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
        return TPCollectionCell.self
    }
    
    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
//        guard let cell = cell as? FocusRecordListDetailCell else {
//            return
//        }
//
//        cell.delegate = self
//        cell.cellStyle = styleForItem(at: index)
//        cell.session = item(at: index) as? FocusSession
    }
    
    override func didSelectItem(at index: Int) {
        guard let record = item(at: index) as? HabitRecord else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
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
    
    /*
    // MARK: - FocusRecordListDetailCellDelegate
    func focusRecordListDetailCell(_ cell: FocusRecordListDetailCell, didClickMore button: UIButton) {
        guard let session = cell.session else { return }
        handleMoreButtonClick(button, session: session)
    }
    
    // MARK: - FocusRecordListBasicCellDelegate
    func focusRecordListBasicCell(_ cell: FocusRecordListBasicCell, didClickMore button: UIButton) {
        guard let session = cell.session else { return }
        handleMoreButtonClick(button, session: session)
    }
    
    // MARK: - Private Methods
    private func handleMoreButtonClick(_ button: UIButton, session: FocusSession) {
        let menuController = FocusRecordMenuController()
        menuController.didSelectMenuActionType = { type in
            switch type {
            case .edit:
                self.editRecord(for: session)
            case .delete:
                self.deleteRecord(for: session)
            }
        }

        let sourceRect = button.bounds.insetBy(dx: -10.0, dy: -10.0)
        menuController.showMenu(from: button,
                                sourceRect: sourceRect,
                                isCovered: true)
    }
    
    func editRecord(for session: FocusSession) {
        FocusPresenter.editRecord(for: session)
    }
    
    func deleteRecord(for session: FocusSession) {
        FocusPresenter.confirmRecordDeletion { confirmed in
            if confirmed {
                focus.deleteSession(session)
            }
        }
    }
     */
}
