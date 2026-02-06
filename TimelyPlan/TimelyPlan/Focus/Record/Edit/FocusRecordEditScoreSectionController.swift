//
//  FocusRecordEditScoreSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/10.
//

import Foundation

class FocusRecordEditScoreSectionController: TPTableItemSectionController {
     
    var score: Int = 0
 
    var didSelectScore: ((Int) -> Void)?

    private lazy var scoreCellItem: OpenCircleScoreCellItem = { [weak self] in
        let cellItem = OpenCircleScoreCellItem()
        cellItem.updater = {
            self?.scoreCellItem.score = self?.score ?? 0
        }
        
        cellItem.didSelectScore = { score in
            self?.score = score
            self?.didSelectScore?(score)
        }
        
        return cellItem
    }()
    
    override init() {
        super.init()
        self.headerItem.height = 50.0
        self.headerItem.title = resGetString("Focus Rating")
        self.headerItem.padding = UIEdgeInsets(top: 15.0, left: 16.0, bottom: 0.0, right: 16.0)
        self.cellItems = [scoreCellItem]
    }
    
}
   
