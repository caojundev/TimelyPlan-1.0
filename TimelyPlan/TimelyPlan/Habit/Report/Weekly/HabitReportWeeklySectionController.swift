//
//  HabitReportWeeklySectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/17.
//

import Foundation
import UIKit

class HabitReportWeeklySectionController: TPCollectionBaseSectionController {

    var periodTasks: [HabitPeriodTask]?
    
    /// 区块布局对象
    private let layout = TPCollectionSectionLayout()
    
    /// 默认单元格样式
    private lazy var cellStyle: TPCollectionCellStyle = {
        let style = TPCollectionCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .secondarySystemFill
        style.cornerRadius = 0.0
        return style
    }()

    let firstWeekday: Weekday
    
    init(periodTasks: [HabitPeriodTask]?, firstWeekday: Weekday) {
        self.firstWeekday = firstWeekday
        self.periodTasks = periodTasks
        super.init()
        self.layout.preferredItemHeight = 70.0
        self.layout.minimumItemsCountPerRow = 1
        self.layout.maximumItemsCountPerRow = 1
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0)
        self.layout.preferredItemWidth = 480.0
        self.layout.lineSpacing = 0.0
        self.layout.interitemSpacing = 0.0
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
        return HabitReportWeeklyCell.self
    }
    
    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        guard let cell = cell as? HabitReportWeeklyCell else {
            return
        }
        
        cell.cellStyle = cellStyle
        cell.scaleWhenHighlighted = false
        cell.periodTask = item(at: index) as? HabitPeriodTask
        cell.reloadData()
    }
    
    override func classForHeader() -> AnyClass? {
        return HabitReportWeeklyHeaderView.self
    }
    
    override func sizeForHeader() -> CGSize {
        return CGSize(width: .greatestFiniteMagnitude, height: 60.0)
    }
    
    override func didDequeHeader(_ headerView: UICollectionReusableView) {
        guard let headerView = headerView as? HabitReportWeeklyHeaderView else {
            return
        }
        
        let padding = UIEdgeInsets(left: self.layout.sectionInset.left,
                                   right: self.layout.sectionInset.right)
        headerView.contentView.padding = padding
        headerView.position = .header
        headerView.firstWeekday = self.firstWeekday
        headerView.reloadData()
    }
    
    override func classForFooter() -> AnyClass? {
        return HabitReportRoundCornerHeaderFooterView.self
    }
    
    override func sizeForFooter() -> CGSize {
        return CGSize(width: .greatestFiniteMagnitude, height: 30.0)
    }
    
    override func didDequeFooter(_ footerView: UICollectionReusableView) {
        guard let footerView = footerView as? HabitReportRoundCornerHeaderFooterView else {
            return
        }
        
        let padding = UIEdgeInsets(left: self.layout.sectionInset.left,
                                   right: self.layout.sectionInset.right)
        footerView.contentView.padding = padding
        footerView.backgroundMargin = 5.0
        footerView.position = .footer
    }
    
    // MARK: -
    override func shouldHighlightItem(at index: Int) -> Bool {
        return true
    }
}

