//
//  FocusStatsDailyViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/11.
//

import Foundation

class FocusStatsDailyViewController: FocusStatsContentViewController {

    init(date: Date = .now) {
        super.init(type: .day, date: date)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func fetchSectionControllers(completion: @escaping([TPCollectionBaseSectionController]) -> Void) {
        focus.fetchDailyStats(forTask: task, timer: timer, on: date) { dataItem in
            let sectionControllers = self.sectionControllers(with: dataItem)
            completion(sectionControllers)
        }
    }
    
    func sectionControllers(with dataItem: FocusStatsDataItem) -> [TPCollectionItemSectionController] {
        let summarySectionController = dataItem.summarySectionController(type: type)
        
        /// 详情
        let detailSectionController = detailSectionController(with: dataItem)
        let heatMapSectionController = heatMapSectionController(with: dataItem)
        let historySessionSectionController = dataItem.historySessionSectionController
        let sectionControllers = [summarySectionController,
                                  detailSectionController,
                                  heatMapSectionController,
                                  historySessionSectionController]
        return sectionControllers
    }
    
    /// 热力图
    func heatMapSectionController(with dataItem: FocusStatsDataItem) -> HourHeatMapSectionController {
        let fragments = dataItem.validFragments
        let sectionController = HourHeatMapSectionController()
        sectionController.cellItem.headerTitle = resGetString("Focus Grids")
        sectionController.cellItem.date = date
        sectionController.levelIndexForDateRange = { dateRange in
            let intersects = fragments?.intersects(dateRange) ?? false
            return intersects ? 1 : 0
        }
        
        return sectionController
    }
}
