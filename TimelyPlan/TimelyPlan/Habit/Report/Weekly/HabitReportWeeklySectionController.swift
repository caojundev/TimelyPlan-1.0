//
//  HabitReportWeeklySectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/17.
//

import Foundation
import UIKit

class HabitReportWeeklySectionController: HabitReportContentSectionController {

    var imageCacher: HabitReportImageCacher?
    
    override init(periodItems: [HabitPeriodItem]?, firstWeekday: Weekday) {
        super.init(periodItems: periodItems, firstWeekday: firstWeekday)
        self.cellStyle.cornerRadius = 0.0
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0)
        self.layout.preferredItemHeight = 60.0
        self.layout.minimumItemsCountPerRow = 1
        self.layout.maximumItemsCountPerRow = 1
        self.layout.preferredItemWidth = 480.0
        self.layout.lineSpacing = 0.0
        self.layout.interitemSpacing = 0.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return HabitReportWeeklyCell.self
    }
    
    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        super.didDequeCell(cell, forItemAt: index)
        guard let cell = cell as? HabitReportWeeklyCell else {
            return
        }
        
        cell.imageCacher = self.imageCacher
        cell.periodItem = item(at: index) as? HabitPeriodItem
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
}

