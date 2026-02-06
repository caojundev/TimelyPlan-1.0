//
//  FocusDefaultTimerSelectSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/2.
//

import Foundation
import UIKit

class FocusDefaultTimerSelectSectionController: TPCollectionBaseSectionController {
    
    override var items: [ListDiffable]? {
        return focus.allDefaultTimers()
    }
    
    lazy var cellStyle: FocusUserTimerCellStyle = {
        let cellStyle = FocusUserTimerCellStyle()
        cellStyle.selectedBackgroundColor = cellStyle.backgroundColor
        return cellStyle
    }()
    
    lazy var layout: FocusTimerListSectionLayout = {
        let layout = FocusTimerListSectionLayout()
        layout.preferredItemWidth = .greatestFiniteMagnitude
        return layout
    }()
    
    override func interitemSpacing() -> CGFloat {
        return self.layout.interitemSpacing
    }
    
    override func lineSpacing() -> CGFloat {
        return self.layout.lineSpacing
    }
    
    override func sectionInset() -> UIEdgeInsets {
        return self.layout.sectionInset
    }
    
    // MARK: - Header
    override func layoutMarginsForHeaderFooterView(_ view: TPCollectionHeaderFooterView) -> UIEdgeInsets {
        var layoutMargins = layout.sectionInset
        layoutMargins.top = 0.0
        layoutMargins.left = 5.0
        layoutMargins.bottom = 0.0
        return layoutMargins
    }
    
    override func sizeForHeader() -> CGSize {
        return CGSize(width: .greatestFiniteMagnitude, height: 40.0)
    }
    
    override func classForHeader() -> AnyClass? {
        return TPCollectionHeaderFooterView.self
    }
    
    override func didDequeHeader(_ headerView: UICollectionReusableView) {
        if let headerView = headerView as? TPCollectionHeaderFooterView {
            headerView.delegate = self
            headerView.padding = UIEdgeInsets(top: 5.0, left: 0.0, bottom: 0, right: 15.0)
            headerView.titleConfig.font = .boldSystemFont(ofSize: 16.0)
            headerView.titleConfig.textColor = resGetColor(.title)
            headerView.title = resGetString("Default Timer")
        }
    }

    override func sizeForItem(at index: Int) -> CGSize {
        self.layout.collectionViewSize = adapter?.collectionViewSize()
        return self.layout.constraintCellSize ?? .zero
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return FocusDefaultTimerSelectCell.self
    }
    
    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        super.didDequeCell(cell, forItemAt: index)
        let cell = cell as! FocusDefaultTimerSelectCell
        cell.timer = item(at: index) as? FocusSystemTimer
    }

    override func styleForItem(at index: Int) -> TPCollectionCellStyle? {
        return cellStyle
    }
    
}
