//
//  WSPluginModuleSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/11.
//

import Foundation
import UIKit

// MARK: - 选择器条目

/// 组件选择器中的一个网格条目。
///
/// 一个模块对应一个条目；声明了预设变体的模块（如分割线的多种样式）
/// 按变体拆成多个条目，共用同一个组件类型。
struct WSPluginPickerEntry {
    
    /// 所属模块
    let module: WSPluginModule
    
    /// 预设变体。为 nil 表示模块本身
    let variant: WSPluginModuleVariant?
    
    /// 条目标题
    var title: String {
        return variant?.title ?? module.displayName
    }
    
    /// 条目图标
    var iconName: String? {
        return variant?.iconName ?? module.iconName
    }
}

// MARK: - 模块组网格区块

/// 模块组网格区块
class WSPluginModuleSectionController: TPCollectionItemSectionController {
    
    enum Metrics {
        
        /// 每行列数
        static let minColumnCount = 4
        static let maxColumnCount = 8
        
        /// 内容与容器边缘的间距
        static let horizontalMargin = 16.0
        
        /// 条目间距
        static let interitemSpacing = 12.0
        
        /// 行间距
        static let lineSpacing = 16.0
        
        /// 组标题高度
        static let headerHeight = 56.0
        
        /// 组标题内边距
        static let headerPadding = UIEdgeInsets(top: 16.0,
                                                left: horizontalMargin,
                                                bottom: 0.0,
                                                right: horizontalMargin)
    }
    
    /// 当前模块组
    let group: WSPluginModuleGroup
    
    /// 选中条目回调
    var didSelectEntry: ((WSPluginPickerEntry) -> Void)?
    
    init(group: WSPluginModuleGroup) {
        self.group = group
        super.init()
        
        /// 列数固定，列宽由容器宽度反推
        layout.minimumItemsCountPerRow = Metrics.minColumnCount
        layout.maximumItemsCountPerRow = Metrics.maxColumnCount
        layout.preferredItemWidth = .greatestFiniteMagnitude
        layout.preferredItemHeight = .greatestFiniteMagnitude
        layout.interitemSpacing = Metrics.interitemSpacing
        layout.lineSpacing = Metrics.lineSpacing
        /// 可用宽度按「左右各留两倍间距」计算，居中反推后区块内边距即为 horizontalMargin
        layout.edgeMargins = UIEdgeInsets(horizontal: Metrics.horizontalMargin)
        
        headerItem.title = group.displayName.uppercased()
        headerItem.titleConfig.font = .systemFont(ofSize: 13.0, weight: .medium)
        headerItem.titleConfig.textColor = .secondaryLabel
        headerItem.size = CGSize(width: .greatestFiniteMagnitude, height: Metrics.headerHeight)
        headerItem.padding = Metrics.headerPadding
        
        self.cellItems = makeCellItems()
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let adapter = self.adapter else {
            return .zero
        }
        
        layout.collectionViewSize = adapter.collectionViewSize()
        let width = layout.itemWidth
        guard width > 0.0 else {
            return .zero
        }
        
        /// 图标方块高度等于列宽，再加上下方标题区域
        return CGSize(width: width, height: width + WSPluginModuleCollectionCell.Metrics.titleAreaHeight)
    }
    
    // MARK: - 条目
    /// 模块组对应的网格条目
    private func makeCellItems() -> [TPCollectionCellItem] {
        var cellItems = [TPCollectionCellItem]()
        for module in group.availableModules {
            for entry in makeEntries(for: module) {
                let cellItem = WSPluginModuleCollectionCellItem()
                cellItem.imageName = entry.iconName
                cellItem.title = entry.title
                /// 数目只在进入画廊的模块上展示，表示可选组件的个数
                cellItem.count = entry.variant == nil && module.pickerStyle == .gallery ? module.types.count : 0
                cellItem.didSelectHandler = { [weak self] in
                    self?.didSelectEntry?(entry)
                }
                
                cellItems.append(cellItem)
            }
        }
        
        return cellItems
    }
    
    /// 模块对应的条目。声明了预设变体时按变体展开成多个条目
    private func makeEntries(for module: WSPluginModule) -> [WSPluginPickerEntry] {
        let variants = module.pickerVariants
        guard !variants.isEmpty else {
            return [WSPluginPickerEntry(module: module, variant: nil)]
        }
        
        return variants.map { WSPluginPickerEntry(module: module, variant: $0) }
    }
}
