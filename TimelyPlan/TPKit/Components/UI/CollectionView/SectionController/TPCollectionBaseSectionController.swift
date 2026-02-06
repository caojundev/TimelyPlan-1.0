//
//  TPCollectionBaseSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/20.
//

import Foundation
import UIKit

protocol TPCollectionSectionControllerDelegate: AnyObject {
    
    func collectionSectionController(_ sectionController: TPCollectionBaseSectionController, didSelectItemAt index: Int)
    
    func collectionSectionController(_ sectionController: TPCollectionBaseSectionController, shouldShowCheckmarkForItemAt index: Int) -> Bool
}

extension TPCollectionSectionControllerDelegate {
    func collectionSectionController(_ sectionController: TPCollectionBaseSectionController, shouldShowCheckmarkForItemAt index: Int) -> Bool {
        return false
    }
}

class TPCollectionBaseSectionController: NSObject, TPCollectionHeaderFooterViewDelegate {

    /// 代理对象
    weak var delegate: TPCollectionSectionControllerDelegate?
    
    /// 适配器
    weak var adapter: TPCollectionViewAdapter?
    
    /// 当前区块索引
    var section: Int = 0
    
    /// 区块唯一标识
    lazy var identifier: String = {
        return UUID().uuidString
    }()

    /// 该区块所有条目
    var items: [ListDiffable]? {
        return nil
    }

    // MARK: - Cell
    func classForCell(at index: Int) -> AnyClass? {
        return TPCollectionCell.self
    }
    
    func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        guard let cell = cell as? TPCollectionCell else {
            return
        }
        
        cell.delegate = self
        cell.cellStyle = styleForItem(at: index)
    }
    
    func sizeForItem(at index: Int) -> CGSize {
        return .zero
    }

    /// 选中区块索引处条目
    func didSelectItem(at index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        delegate?.collectionSectionController(self, didSelectItemAt: index)
    }

    // MARK: - Header
    func classForHeader() -> AnyClass? {
        return TPCollectionHeaderFooterView.self
    }
    
    func sizeForHeader() -> CGSize {
        return .zero
    }
    
    func didDequeHeader(_ headerView: UICollectionReusableView) {
        if let headerView = headerView as? TPCollectionHeaderFooterView {
            headerView.delegate = self
        }
    }
    
    // MARK: - Footer
    func classForFooter() -> AnyClass? {
        return TPCollectionHeaderFooterView.self
    }
    
    func sizeForFooter() -> CGSize {
        return .zero
    }
    
    func didDequeFooter(_ footerView: UICollectionReusableView) {
        if let footerView = footerView as? TPCollectionHeaderFooterView {
            footerView.delegate = self
        }
    }
    
    // MARK: - Other Providers
    func sectionInset() -> UIEdgeInsets {
        return .zero
    }
    
    func interitemSpacing() -> CGFloat {
        return 0.0
    }
    
    func lineSpacing() -> CGFloat {
        return 0.0
    }
    
    func shouldHighlightItem(at index: Int) -> Bool {
        return true
    }
    
    func shouldShowCheckmarkForItem(at index: Int) -> Bool {
        let bShow = delegate?.collectionSectionController(self, shouldShowCheckmarkForItemAt: index)
        return bShow ?? false
    }
    
    func styleForItem(at index: Int) -> TPCollectionCellStyle? {
        return adapter?.cellStyle
    }
    
    /// 获取当前区块特定索引处的条目
    func item(at index: Int) -> AnyObject? {
        if let items = adapter?.items(for: self), index < items.count {
            return items[index]
        }

        return nil
    }
    
    func cellForItem(at index: Int) -> UICollectionViewCell? {
        let indexPath = IndexPath(row: index, section: section)
        return adapter?.cellForItem(at: indexPath)
    }
    
    /// 当前区块条目数
    var itemsCount: Int {
        if let items = adapter?.items(for: self) {
            return items.count
        }

        return 0
    }
    
    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }

    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? TPCollectionBaseSectionController {
            return self.identifier == object.identifier
        }
        
        return false
    }
    
    // MARK: - TPCollectionHeaderFooterViewDelegate
    func layoutMarginsForHeaderFooterView(_ view: TPCollectionHeaderFooterView) -> UIEdgeInsets {
        return .zero
    }
}
