//
//  TPCollectionSectionLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/25.
//

import Foundation
import UIKit

class TPCollectionSectionLayout {
    
    /// 单元格限制尺寸
    private var _constraintCellSize: CGSize?
    var constraintCellSize: CGSize? {
        layoutIfNeeded()
        return _constraintCellSize
    }

    /// 集合视图尺寸
    var collectionViewSize: CGSize? {
        didSet {
            if collectionViewSize != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    private var _sectionInset: UIEdgeInsets = .zero
    var sectionInset: UIEdgeInsets {
        layoutIfNeeded()
        return _sectionInset
    }
    
    private var _itemWidth: CGFloat = 0.0
    var itemWidth: CGFloat {
        layoutIfNeeded()
        return _itemWidth
    }
    
    /// 条目内间距
    var interitemSpacing: CGFloat = 15.0
    
    /// 行间距
    var lineSpacing: CGFloat = 15.0
    
    /// 边界间距
    var edgeMargins: UIEdgeInsets = .zero
    
    /// 首选条目宽度
    var preferredItemWidth: CGFloat = .greatestFiniteMagnitude
    
    /// 首选条目高度
    var preferredItemHeight: CGFloat = .greatestFiniteMagnitude
    
    /// 最小行条目数
    var minimumItemsCountPerRow: Int = 1

    /// 最大行条目数
    var maximumItemsCountPerRow: Int = 1
    
    /// 是否需要计算布局
    private var shouldLayout: Bool = true
    
    func setNeedsLayout() {
        shouldLayout = true
    }
    
    func layoutIfNeeded() {
        if shouldLayout {
            shouldLayout = false
            layout()
        }
    }
    
    /// 计算布局
    private func layout() {
        guard let collectionViewSize = collectionViewSize else {
            return
        }

        let layoutMaxWidth = collectionViewSize.width - edgeMargins.horizontalLength
        var itemWidth = preferredItemWidth
        if itemWidth > layoutMaxWidth {
            itemWidth = layoutMaxWidth
        }
        
        var itemsCountPerRow = Int((layoutMaxWidth + interitemSpacing) / (interitemSpacing + preferredItemWidth))
        if itemsCountPerRow >= minimumItemsCountPerRow {
            /// 超过允许最大条目数
            if itemsCountPerRow > maximumItemsCountPerRow {
                itemsCountPerRow = maximumItemsCountPerRow
            }
        } else {
            itemsCountPerRow = minimumItemsCountPerRow
            itemWidth = (layoutMaxWidth + interitemSpacing) / CGFloat(itemsCountPerRow) - interitemSpacing
        }
        
        let contentWidth = CGFloat(itemsCountPerRow) * (itemWidth + interitemSpacing) - interitemSpacing
        let edgeMargin = (collectionViewSize.width - contentWidth) / 2.0
        _sectionInset = UIEdgeInsets(top: edgeMargins.top,
                                     left: edgeMargin,
                                     bottom: edgeMargins.bottom,
                                     right: edgeMargin)
        _itemWidth = itemWidth
        _constraintCellSize = CGSize(width: _itemWidth, height: preferredItemHeight)
    }
}
