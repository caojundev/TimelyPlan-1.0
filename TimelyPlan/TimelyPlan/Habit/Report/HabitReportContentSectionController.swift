//
//  HabitReportContentSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/17.
//

import Foundation
import UIKit

class HabitReportContentSectionController: TPCollectionBaseSectionController {

    var periodTasks: [HabitPeriodTask]?
    
    let firstWeekday: Weekday
    
    /// 区块布局对象
    let layout = TPCollectionSectionLayout()
    
    /// 默认单元格样式
    private(set) lazy var cellStyle: TPCollectionCellStyle = {
        let style = TPCollectionCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.cornerRadius = 0.0
        return style
    }()

    init(periodTasks: [HabitPeriodTask]?, firstWeekday: Weekday) {
        self.firstWeekday = firstWeekday
        self.periodTasks = periodTasks
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0)
    }
    
    override var items: [ListDiffable]? {
        return periodTasks
    }
    
    override func sectionInset() -> UIEdgeInsets {
        return layout.sectionInset
    }
    
    override func interitemSpacing() -> CGFloat {
        return layout.interitemSpacing
    }
    
    override func lineSpacing() -> CGFloat {
        return layout.lineSpacing
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let adapter = self.adapter else {
            return .zero
        }
        
        self.layout.collectionViewSize = adapter.collectionViewSize()
        let constraintCellSize = self.layout.constraintCellSize ?? adapter.cellSize
        return constraintCellSize
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return TPCollectionCell.self
    }
    
    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        guard let cell = cell as? TPCollectionCell else {
            return
        }
        
        cell.cellStyle = cellStyle
        cell.scaleWhenHighlighted = false
    }
    
    // MARK: -
    override func shouldHighlightItem(at index: Int) -> Bool {
        return false
    }
}
