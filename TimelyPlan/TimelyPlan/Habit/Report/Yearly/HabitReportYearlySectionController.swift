//
//  HabitReportYearlySectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/17.
//

import Foundation

class HabitReportYearlySectionController: TPCollectionBaseSectionController {

    var periodTasks: [HabitPeriodTask]?
    
    /// 区块布局对象
    private let layout = TPCollectionSectionLayout()
    
    init(periodTasks: [HabitPeriodTask]?) {
        self.periodTasks = periodTasks
        super.init()
        self.layout.preferredItemHeight = 100.0
        self.layout.minimumItemsCountPerRow = 1
        self.layout.maximumItemsCountPerRow = 1
        self.layout.edgeMargins = UIEdgeInsets(value: 16.0)
        self.layout.preferredItemWidth = 480.0
        self.layout.lineSpacing = 10.0
        self.layout.interitemSpacing = 10.0
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
        
        cell.cellStyle = adapter?.cellStyle
    }

    // MARK: -
    override func shouldHighlightItem(at index: Int) -> Bool {
        return true
    }
}

