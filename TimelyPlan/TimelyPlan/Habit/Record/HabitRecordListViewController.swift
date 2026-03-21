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
        self.contentInset = UIEdgeInsets(bottom: 80.0)
        habit.addUpdater(self, for: [.record])
    }
    
    override func placeholderView() -> UIView? {
        let view = TPDefaultPlaceholderView()
        view.image = resGetImage("placeholder_record_80")
        view.title = resGetString("No Habit Record")
        view.titleColor = .lightGray
        return view
    }
    
    override func fetchSectionControllers(completion: @escaping ([TPCollectionBaseSectionController]) -> Void) {
        Habit.fetchDailyItemsGroupedByDay(in: self.dateRange) { results in
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
        var sectionControllers = [HabitRecordListSectionController]()
        let sortedDailyItems = dayRecords.sorted(by: { $0.key < $1.key })
        for (day, items) in sortedDailyItems {
            guard let date = Date.dateFromDayIntegerKey(day) else {
                continue
            }
            
            let sectionController = HabitRecordListSectionController(date: date, dailyItems: items)
            sectionControllers.append(sectionController)
        }

        return sectionControllers
    }
    
    // MARK: - HabitRecordProcessorDelegate
    func didUpdateHabitRecord(_ record: HabitRecord, for task: HabitTask, on date: Date, with change: HabitRecordChange) {
        self.reloadData {
            let dailyItem = HabitDailyItem(record: record, task: task)
            self.adapter.scrollToItem(dailyItem, at: .centeredVertically, animated: true) { _ in
                self.adapter.commitFocusAnimation(for: dailyItem)
            }
        }
    }
    
    func didDeleteHabitRecords(for task: HabitTask, in period: HabitDatePeriod) {
        self.reloadData()
    }
}
