//
//  HabitRecordListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/20.
//

import Foundation
import UIKit

class HabitRecordListViewController: StatsContentViewController,
                                     HabitRecordProcessorDelegate,
                                     SettingAgentObserver {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.placeholderProvider.emptyImage = resGetImage("placeholder_record_80")
        self.placeholderProvider.emptyTitle = resGetString("No Habit Record")
        self.contentInset = UIEdgeInsets(bottom: 80.0)
        HabitSetting.shared.addObserver(self, forKey: .recordSortOrder)
        HabitRepository.addUpdater(self, for: [.record])
    }
    
    func settingAgentDidChangeValue(for keyName: String) {
        if keyName == HabitSetting.Key.recordSortOrder.name {
            performUpdate()
        }
    }
    
    private func listModeChanged() {
        guard let sectionControllers = self.sectionControllers as? [FocusRecordListSectionController] else {
            return
        }
        
        let mode = FocusState.shared.recordListMode
        sectionControllers.forEach {
            $0.mode = mode
        }
        
        adapter.reloadData()
    }
    
    override func fetchSectionControllers(completion: @escaping ([TPCollectionBaseSectionController]) -> Void) {
        HabitRepository.fetchDailyItemsGroupedByDay(in: self.dateRange) { results in
            let sectionControllers: [HabitRecordListSectionController]
            if let results = results, results.count > 0 {
                sectionControllers = self.sectionControllers(with: results)
            } else {
                sectionControllers = []
            }

            completion(sectionControllers)
        }
    }
    
    private func sectionControllers(with dayRecords: HabitGroupedDailyItems) -> [HabitRecordListSectionController] {
        let sortOrder = HabitSetting.shared.recordSortOrder
        var sectionControllers = [HabitRecordListSectionController]()
        let sortedDayRecords: [Dictionary<Int32, [HabitDailyItem]>.Element]
        switch sortOrder {
        case .ascending:
            sortedDayRecords = dayRecords.sorted(by: { $0.key < $1.key })
        case .descending:
            sortedDayRecords = dayRecords.sorted(by: { $0.key > $1.key })
        }

        for (day, items) in sortedDayRecords {
            guard let date = Date.dateFromDayIntegerKey(day) else {
                continue
            }
            
            let sortedItems: [HabitDailyItem]
            switch sortOrder {
            case .ascending:
                sortedItems = items.orderedDailyItems(ascending: true)
            case .descending:
                sortedItems = items.orderedDailyItems(ascending: false)
            }

            let sectionController = HabitRecordListSectionController(date: date,
                                                                     dailyItems: sortedItems)
            sectionControllers.append(sectionController)
        }

        return sectionControllers
    }
    
    // MARK: - HabitRecordProcessorDelegate
    func remoteHabitRecordDidChange() {
        performUpdate()
    }
    
    func didUpdateHabitRecord(_ record: HabitRecord, for task: HabitTask, on date: Date, with change: HabitRecordChange) {
        performUpdate { [weak self] in
            let dailyItem = HabitDailyItem(record: record, task: task)
            self?.adapter.revealItem(dailyItem, autoScroll: true)
        }
    }
    
    func didDeleteHabitRecords(for task: HabitTask?, in dateRange: DateRange) {
        performUpdate()
    }
}
