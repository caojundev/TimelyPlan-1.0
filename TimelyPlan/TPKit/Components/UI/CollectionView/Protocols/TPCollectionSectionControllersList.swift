//
//  TPCollectionSectionControllersList.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/20.
//

import Foundation

protocol TPCollectionSectionControllersList: TPCollectionViewAdapterDataSource,
                                             TPCollectionViewAdapterDelegate {
    /// 返回列表区块控制器数组
    var sectionControllers: [TPCollectionBaseSectionController]? {get set}
}

extension TPCollectionSectionControllersList {
   
    // MARK: - TPCollectionViewAdapterDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return sectionControllers
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        let sectionController = sectionObject as? TPCollectionBaseSectionController
        sectionController?.adapter = adapter /// 设置adapter
        return sectionController?.items
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        let sectionController = sectionController(for: adapter, inSection: indexPath.section)
        return sectionController.classForCell(at: indexPath.item)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let sectionController = sectionController(for: adapter, inSection: indexPath.section)
        sectionController.didDequeCell(cell, forItemAt: indexPath.item)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionController = sectionController(for: adapter, inSection: indexPath.section)
        return sectionController.sizeForItem(at: indexPath.item)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionController = sectionController(for: adapter, inSection: section)
        return sectionController.sectionInset()
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, interitemSpacingForSectionAt section: Int) -> CGFloat {
        let sectionController = sectionController(for: adapter, inSection: section)
        return sectionController.interitemSpacing()
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, lineSpacingForSectionAt section: Int) -> CGFloat {
        let sectionController = sectionController(for: adapter, inSection: section)
        return sectionController.lineSpacing()
    }
    
    // MARK: - Header
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForHeaderInSection section: Int) -> CGSize {
        let sectionController = sectionController(for: adapter, inSection: section)
        return sectionController.sizeForHeader()
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        let sectionController = sectionController(for: adapter, inSection: section)
        return sectionController.classForHeader()
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        let sectionController = sectionController(for: adapter, inSection: section)
        sectionController.didDequeHeader(headerView)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, updateHeaderInSection section: Int) {
        if let headerView = adapter.headerView(in: section) {
            let sectionController = sectionController(for: adapter, inSection: section)
            return sectionController.didDequeHeader(headerView)
        }
    }
    
    
    // MARK: - Footer
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForFooterInSection section: Int) -> CGSize {
        let sectionController = sectionController(for: adapter, inSection: section)
        return sectionController.sizeForFooter()
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, classForFooterInSection section: Int) -> AnyClass? {
        let sectionController = sectionController(for: adapter, inSection: section)
        return sectionController.classForFooter()
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeFooter footerView: UICollectionReusableView, inSection section: Int) {
        let sectionController = sectionController(for: adapter, inSection: section)
        sectionController.didDequeFooter(footerView)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, updateFooterInSection section: Int) {
        if let footerView = adapter.footerView(in: section) {
            let sectionController = sectionController(for: adapter, inSection: section)
            return sectionController.didDequeFooter(footerView)
        }
    }
    
    // MARK: -
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let sectionController = sectionController(for: adapter, inSection: indexPath.section)
        return sectionController.shouldHighlightItem(at: indexPath.item)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool {
        let sectionController = sectionController(for: adapter, inSection: indexPath.section)
        return sectionController.shouldShowCheckmarkForItem(at: indexPath.item)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        let sectionController = sectionController(for: adapter, inSection: indexPath.section)
        return sectionController.didSelectItem(at: indexPath.row)
    }
    
    // MARK: - Helpers
    private func sectionController(for adapter: TPCollectionViewAdapter,  inSection section: Int) -> TPCollectionBaseSectionController {
        let controller = adapter.object(at: section) as! TPCollectionBaseSectionController
        controller.section = section
        return controller
    }
}
