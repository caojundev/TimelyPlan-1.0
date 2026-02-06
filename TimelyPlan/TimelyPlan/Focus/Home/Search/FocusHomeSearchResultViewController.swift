//
//  FocusHomeSearchResultViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/9.
//

import Foundation

class FocusHomeSearchResultViewController: FocusTimerSearchResultViewController {
    
    var didClickStart: ((FocusTimer) -> Void)? {
        didSet {
            let sectionController = self.resultSectionController as? FocusHomeSearchResultSectionController
            sectionController?.didClickStart = didClickStart
        }
    }
    
    override init(timer: FocusTimer? = nil) {
        super.init(timer: timer)
        self.resultSectionController = FocusHomeSearchResultSectionController()
        self.resultSectionController.delegate = self
        self.resultSectionController.layout.preferredItemWidth = kFocusHomeContentMaxWidth
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class FocusHomeSearchResultSectionController: FocusTimerSearchResultSectionController,
                                                FocusTimerStartCellDelegate {
    
    /// 点击开始回调
    var didClickStart: ((FocusTimer) -> Void)?
    
    override func classForCell(at index: Int) -> AnyClass? {
        return FocusTimerStartCell.self
    }
    
    func FocusTimerStartCellDidClickStart(_ cell: FocusTimerStartCell) {
        if let timer = cell.timer {
            didClickStart?(timer)
        }
    }
}
