//
//  TPCollectionViewAdapterDelegate.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/18.
//

import Foundation

protocol TPCollectionViewAdapterDelegate: UIScrollViewDelegate {
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath)
    func adapter(_ adapter: TPCollectionViewAdapter, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    func adapter(_ adapter: TPCollectionViewAdapter, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass?
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath)
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool
    func adapter(_ adapter: TPCollectionViewAdapter, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool
    
    // MARK: - Header Footer
    /// 通知更新区块索引处对应的头视图
    func adapter(_ adapter: TPCollectionViewAdapter, updateHeaderInSection section: Int)
    func adapter(_ adapter: TPCollectionViewAdapter, updateFooterInSection section: Int)
    func adapter(_ adapter: TPCollectionViewAdapter, classForHeaderInSection section: Int) -> AnyClass?
    func adapter(_ adapter: TPCollectionViewAdapter, classForFooterInSection section: Int) -> AnyClass?
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeHeader headerView: UICollectionReusableView, inSection section: Int)
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeFooter footerView: UICollectionReusableView, inSection section: Int)
    
    /// 索引所在区块头标题
    func adapter(_ adapter: TPCollectionViewAdapter, titleForHeaderInSection section: Int) -> String?
    
    /// 索引所在区块脚标题
    func adapter(_ adapter: TPCollectionViewAdapter, titleForFooterInSection section: Int) -> String?
    
    // MARK: - FlowLayout
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForHeaderInSection section: Int) -> CGSize
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForFooterInSection section: Int) -> CGSize
    func adapter(_ adapter: TPCollectionViewAdapter, insetForSectionAt section: Int) -> UIEdgeInsets
    func adapter(_ adapter: TPCollectionViewAdapter, lineSpacingForSectionAt section: Int) -> CGFloat
    func adapter(_ adapter: TPCollectionViewAdapter, interitemSpacingForSectionAt section: Int) -> CGFloat
}

extension TPCollectionViewAdapterDelegate {
    
    // MARK: - 标题
    func adapter(_ adapter: TPCollectionViewAdapter, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: - Cell
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return adapter.cellClass
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        if let cell = cell as? TPCollectionCell {
            cell.delegate = self
            cell.cellStyle = adapter.cellStyle
        }
        
        cell.padding = adapter.cellPadding
    }

    
    func adapter(_ adapter: TPCollectionViewAdapter, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? TPCollectionCell {
            cell.willDisplay()
        }
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? TPCollectionCell {
            cell.didEndDisplay()
        }
    }
    
    // MARK: - Header
    func adapter(_ adapter: TPCollectionViewAdapter, updateHeaderInSection section: Int) {
        
    }

    func adapter(_ adapter: TPCollectionViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        return adapter.headerClass
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        
        if let headerView = headerView as? TPCollectionHeaderFooterView {
            headerView.titleConfig.font = BOLD_BODY_FONT
            headerView.titleConfig.textColor = resGetColor(.insetGroupedTableSectionHeaderTitle)
            headerView.title = self.adapter(adapter, titleForHeaderInSection: section)
        }
    }
    
    // MARK: - Footer
    func adapter(_ adapter: TPCollectionViewAdapter, updateFooterInSection section: Int) {
        
    }

    func adapter(_ adapter: TPCollectionViewAdapter, classForFooterInSection section: Int) -> AnyClass? {
        return adapter.footerClass
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeFooter footerView: UICollectionReusableView, inSection section: Int) {
        
        if let footerView = footerView as? TPCollectionHeaderFooterView {
            footerView.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
            footerView.titleConfig.textColor = .systemGray5
            footerView.title = self.adapter(adapter, titleForFooterInSection: section)
        }
    }
    
    // MARK: - FlowLayout
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionSize = adapter.collectionViewSize()
        var size = adapter.cellSize
        let sectionInset = self.adapter(adapter, insetForSectionAt: indexPath.section)
        if adapter.scrollDirection == .vertical {
            /// 限制宽度
            let maxContentWidth = collectionSize.width - sectionInset.horizontalLength
            size.width = min(size.width, maxContentWidth)
        } else {
            /// 限制高度
            let maxContentHeight = collectionSize.height - sectionInset.verticalLength
            size.height = min(size.height, maxContentHeight)
        }
        
        return size
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForHeaderInSection section: Int) -> CGSize {
        return adapter.headerSize
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForFooterInSection section: Int) -> CGSize {
        return adapter.footerSize
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, insetForSectionAt section: Int) -> UIEdgeInsets {
        return adapter.sectionInset
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, lineSpacingForSectionAt section: Int) -> CGFloat {
        return adapter.lineSpacing
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, interitemSpacingForSectionAt section: Int) -> CGFloat {
        return adapter.interitemSpacing
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        
    }
}
