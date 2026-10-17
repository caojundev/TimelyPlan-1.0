//
//  WSDashboardLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation
import UIKit

/// 工作台仪表盘布局计算。
///
/// 与系统小组件一致，以小号组件作为网格单元（1x1）：
/// - 小号：1 列 1 行
/// - 中号：2 列 1 行
/// - 大号：2 列 2 行
///
/// 所有组件尺寸都由容器宽度推导，`interitemSpacing` 与 `lineSpacing` 保持固定值，
/// 不随容器宽度变化；`sectionInset` 则由内容宽度在容器内居中反推得出。
class WSDashboardLayout {
    
    /// 网格列数。小号组件占 1 列，中号 / 大号组件占满 2 列。
    static let columnCount: CGFloat = 2
    
    /// 组件间距。固定值，不随容器宽度变化。
    let interitemSpacing: CGFloat
    
    /// 行间距。固定值，不随容器宽度变化。
    let lineSpacing: CGFloat
    
    /// 外部边距。用于限制组件与容器边缘的距离。
    let edgeMargins: UIEdgeInsets
    
    /// 单元格尺寸计算，复用列表页统一的区块布局
    private let sectionLayout = TPCollectionSectionLayout()
    
    init(edgeMargins: UIEdgeInsets = UIEdgeInsets(horizontal: 16.0, vertical: 16.0),
         interitemSpacing: CGFloat = 16.0,
         lineSpacing: CGFloat = 16.0) {
        self.edgeMargins = edgeMargins
        self.interitemSpacing = interitemSpacing
        self.lineSpacing = lineSpacing
        
        sectionLayout.edgeMargins = edgeMargins
        sectionLayout.interitemSpacing = interitemSpacing
        sectionLayout.lineSpacing = lineSpacing
        /// 列数固定为 columnCount，列宽则由容器宽度反推
        sectionLayout.minimumItemsCountPerRow = Int(Self.columnCount)
        sectionLayout.maximumItemsCountPerRow = Int(Self.columnCount)
        sectionLayout.preferredItemWidth = .greatestFiniteMagnitude
        /// 每个条目的高度取决于组件尺寸，不使用统一的 constraintCellSize
        sectionLayout.preferredItemHeight = .greatestFiniteMagnitude
    }
    
    /// 容器尺寸。赋值后会在下次取用时重新计算各尺寸。
    var containerSize: CGSize? {
        get {
            return sectionLayout.collectionViewSize
        }
        
        set {
            sectionLayout.collectionViewSize = newValue
        }
    }
    
    /// 网格单元的边长（等于小号组件的宽 / 高）
    var unitLength: CGFloat {
        return sectionLayout.itemWidth
    }
    
    /// 区块内边距。
    ///
    /// 左右内边距由「内容宽度在容器内居中」反推而来：
    /// 内容宽度 = 2 * 单元边长 + interitemSpacing = 容器宽度 - 2 * 左右内边距。
    /// 因此无论容器宽度如何变化，组件之间的 `interitemSpacing` 始终等于固定值。
    var sectionInset: UIEdgeInsets {
        return sectionLayout.sectionInset
    }
    
    /// 容器尺寸变化后重新计算布局
    func updateLayoutIfNeeded(containerSize: CGSize) {
        self.containerSize = containerSize
    }
    
    /// 指定尺寸组件的条目尺寸
    func itemSize(for size: WSPluginSize) -> CGSize {
        let unitLength = self.unitLength
        guard unitLength > 0.0 else {
            return .zero
        }
        
        switch size {
        case .small:
            return CGSize(width: unitLength, height: unitLength)
        case .medium:
            return CGSize(width: rowLength(unitLength: unitLength), height: unitLength)
        case .large:
            let length = rowLength(unitLength: unitLength)
            return CGSize(width: length, height: length)
        }
    }
    
    /// 指定组件的条目尺寸。尺寸取自注册的组件提供者。
    func itemSize(for plugin: WSPlugin) -> CGSize {
        return itemSize(for: plugin.type.size)
    }
    
    /// 占满整行的长度（中号 / 大号的宽度）
    private func rowLength(unitLength: CGFloat) -> CGFloat {
        return Self.columnCount * unitLength + interitemSpacing
    }
}
