//
//  FocusStatsHistorySessionCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/18.
//

import Foundation
import UIKit

class FocusStatsHistorySessionSectionController: FocusStatsHistorySectionController {

    var dataItem: FocusStatsDataItem?
    
    var sessions: [FocusSession]? {
        didSet {
            self.updateCellItems()
        }
    }
    
    init(sessions: [FocusSession]? = nil) {
        self.sessions = sessions
        super.init()
        self.updateCellItems()
    }

    override func updateCellItems() {
        guard let sessions = sessions, sessions.count > 0 else {
            self.cellItems = [emptyCellItem]
            return
        }
        
        var cellItems = [FocusStatsHistorySessionCellItem]()
        for session in sessions {
            let cellItem = FocusStatsHistorySessionCellItem(session: session)
            cellItem.delegate = self /// 单元格
            cellItems.append(cellItem)
        }
        
        self.cellItems = cellItems
    }
    
    override func didSelectItem(at index: Int) {
        super.didSelectItem(at: index)
        guard let cellItem = item(at: index) as? FocusStatsHistorySessionCellItem,
              let date = cellItem.session.startDate else {
            return
        }
        
        FocusPresenter.showRecords(forTask: dataItem?.task,
                                   timer: dataItem?.timer,
                                   type: .day,
                                   date: date)
    }
}

class FocusStatsHistorySessionCellItem: TPCollectionCellItem {
    
    var session: FocusSession
    
    init(session: FocusSession) {
        self.session = session
        super.init()
        self.registerClass = FocusStatsHistorySessionCell.self
        self.size = CGSize(width: .greatestFiniteMagnitude, height: 130.0)
        self.contentPadding = UIEdgeInsets(horizontal: 16.0, vertical: 10.0)
    }
}

class FocusStatsHistorySessionCell: FocusStatsHistoryCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            guard let cellItem = cellItem as? FocusStatsHistorySessionCellItem else {
                infoView.resetTitle()
                return
            }
            
            let session = cellItem.session
            let pauseCount = session.pauses?.count ?? 0
            headerLabel.attributed.text = session.attributedDateRangeString()
            infoView[0].title = Duration(session.duration).attributedTitle()
            infoView[1].title = "\(session.score)"
            infoView[2].title = pauseCount > 0 ? "\(pauseCount)" : "--"
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        infoView[0].subtitle = resGetString("Focus duration")
        infoView[1].subtitle = resGetString("Score")
        infoView[2].subtitle = resGetString("Pause")
    }
}
