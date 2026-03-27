//
//  BaseTaskBindSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/27.
//

import Foundation

class TaskBindSectionLayout: TPCollectionSectionLayout {

    override init() {
        super.init()
        self.edgeMargins = UIEdgeInsets(horizontal: 15.0, vertical: 10.0)
        self.minimumItemsCountPerRow = 1
        self.maximumItemsCountPerRow = 1
        self.lineSpacing = 10.0
        self.interitemSpacing = 10.0
        self.preferredItemHeight = 70.0
        self.preferredItemWidth = 560.0
    }
}

class TaskBindCellStyle: TPCollectionCellStyle {
    
    override init() {
        super.init()
        self.backgroundColor = .secondarySystemGroupedBackground
        self.selectedBackgroundColor = .tertiarySystemGroupedBackground
        self.cornerRadius = 12.0
    }
}

class BaseTaskBindSectionController: TPCollectionBaseSectionController {
    
    /// 显示头视图
    var showHeader: Bool = false
    
    /// 头高度
    var headerHeight: CGFloat = 0.0
    
    let cellStyle = TaskBindCellStyle()
    
    let layout = TaskBindSectionLayout()
    
    var tasks: [ListDiffable]?
    
    override init() {
        super.init()
        self.layout.preferredItemWidth = .greatestFiniteMagnitude
    }
    
    override var items: [ListDiffable]? {
        return self.tasks
    }
    
    override func interitemSpacing() -> CGFloat {
        return layout.interitemSpacing
    }
    
    override func lineSpacing() -> CGFloat {
        return layout.lineSpacing
    }
    
    override func sectionInset() -> UIEdgeInsets {
        return layout.sectionInset
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        layout.collectionViewSize = adapter?.collectionViewSize()
        return layout.constraintCellSize ?? .zero
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return TPCollectionCell.self
    }

    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        super.didDequeCell(cell, forItemAt: index)
    }
    
    override func styleForItem(at index: Int) -> TPCollectionCellStyle? {
        return cellStyle
    }
    
    override func didSelectItem(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        
        /// 通知delegate
        delegate?.collectionSectionController(self, didSelectItemAt: index)
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
        return CGSize(width: .greatestFiniteMagnitude, height: headerHeight)
    }
       
    override func classForHeader() -> AnyClass? {
        return TPCollectionHeaderFooterView.self
    }

    override func didDequeHeader(_ headerView: UICollectionReusableView) {
       guard let headerView = headerView as? TPCollectionHeaderFooterView else {
          return
       }
        
        headerView.padding = UIEdgeInsets(top: 5.0, left: 0.0, bottom: 0, right: 15.0)
        headerView.titleConfig.font = .boldSystemFont(ofSize: 16.0)
        headerView.titleConfig.textColor = resGetColor(.title)
    }
    
}
