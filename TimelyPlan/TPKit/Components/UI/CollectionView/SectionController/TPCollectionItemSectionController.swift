//
//  TPCollectionItemSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/20.
//

import Foundation

class TPCollectionItemSectionController: TPCollectionBaseSectionController {

    /// 头条目
    lazy var headerItem: TPCollectionHeaderFooterItem = {
        let item = TPCollectionHeaderFooterItem()
        item.titleConfig.textColor = resGetColor(.insetGroupedTableSectionHeaderTitle)
        return item
    }()
    
    /// 脚条目
    lazy var footerItem: TPCollectionHeaderFooterItem = {
        let item = TPCollectionHeaderFooterItem()
        return item
    }()
    
    /// 单元格条目数组
    var cellItems: [TPCollectionCellItem]?
    
    /// 区块布局对象
    lazy var layout: TPCollectionSectionLayout = {
        return TPCollectionSectionLayout()
    }()
    
    override var items: [ListDiffable]? {
        return cellItems
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
        let cellItem = item(at: index) as! TPCollectionCellItem
        cellItem.updater?() /// 更新单元格数据
        cellItem.constraintSize = constraintCellSize
        var cellSize = constraintCellSize
        if let size = cellItem.size {
            let width = min(constraintCellSize.width, size.width)
            let height = min(constraintCellSize.height, size.height)
            cellSize = CGSize(width: width, height: height)
        }
        
        /// 未知的宽度和高度
        if cellSize.width == .greatestFiniteMagnitude {
            cellSize.width = 0.0
        }
        
        if cellSize.height == .greatestFiniteMagnitude {
            cellSize.height = 0.0
        }
        
        return cellSize
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        let cellItem = item(at: index) as! TPCollectionCellItem
        return cellItem.registerClass
    }
    
    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        guard let cell = cell as? TPCollectionCell else {
            return
        }
        
        let cellItem = item(at: index) as! TPCollectionCellItem
        cell.cellItem = cellItem
        cell.delegate = cellItem.delegate ?? self
        cellItem.updater?()
        
        /// 设置样式
        if let cellStyle = cellItem.style {
            cell.cellStyle = cellStyle
        } else {
            cell.cellStyle = styleForItem(at: index)
        }
    }

    // MARK: - Header
    override func sizeForHeader() -> CGSize {
        return headerItem.size
    }
    
    override func classForHeader() -> AnyClass? {
        return headerItem.registerClass
    }
    
    override func didDequeHeader(_ headerView: UICollectionReusableView) {
        if let headerView = headerView as? TPCollectionHeaderFooterView {
            headerView.delegate = self
            headerView.headerFooterItem = headerItem
        }
    }
    
    // MARK: - Footer
    override func sizeForFooter() -> CGSize {
        return footerItem.size
    }
    
    override func classForFooter() -> AnyClass? {
        return footerItem.registerClass
    }
    
    override func didDequeFooter(_ footerView: UICollectionReusableView) {
        if let footerView = footerView as? TPCollectionHeaderFooterView {
            footerView.delegate = self
            footerView.headerFooterItem = footerItem
        }
    }
    
    // MARK: -
    override func shouldHighlightItem(at index: Int) -> Bool {
        let cellItem = item(at: index) as! TPCollectionCellItem
        return cellItem.canHighlight
    }

    override func shouldShowCheckmarkForItem(at index: Int) -> Bool {
        let cellItem = item(at: index) as! TPCollectionCellItem
        return cellItem.isChecked
    }
 
    override func didSelectItem(at index: Int) {
        let cellItem = item(at: index) as! TPCollectionCellItem
        guard cellItem.canHighlight else {
            return
        }
                
        super.didSelectItem(at: index)
        cellItem.didSelectHandler?()
    }
}
