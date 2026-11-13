//
//  WSPluginModuleSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/11.
//

import Foundation
import UIKit

// MARK: - 模块组网格区块

/// 模块组网格区块
class WSPluginModuleSectionController: TPCollectionItemSectionController {
    
    enum Metrics {
        
        /// 每行列数
        static let columnCount = 4
        
        /// 内容与容器边缘的间距
        static let horizontalMargin = 16.0
        
        /// 条目间距
        static let interitemSpacing = 12.0
        
        /// 行间距
        static let lineSpacing = 16.0
        
        /// 组标题高度
        static let headerHeight = 40.0
        
        /// 组标题内边距
        static let headerPadding = UIEdgeInsets(top: 16.0,
                                                left: horizontalMargin,
                                                bottom: 0.0,
                                                right: horizontalMargin)
    }
    
    /// 当前模块组
    let group: WSPluginModuleGroup
    
    /// 选中模块回调
    var didSelectModule: ((WSPluginModule) -> Void)?
    
    init(group: WSPluginModuleGroup) {
        self.group = group
        super.init()
        
        /// 列数固定，列宽由容器宽度反推
        layout.minimumItemsCountPerRow = Metrics.columnCount
        layout.maximumItemsCountPerRow = Metrics.columnCount
        layout.preferredItemWidth = .greatestFiniteMagnitude
        layout.preferredItemHeight = .greatestFiniteMagnitude
        layout.interitemSpacing = Metrics.interitemSpacing
        layout.lineSpacing = Metrics.lineSpacing
        /// 可用宽度按「左右各留两倍间距」计算，居中反推后区块内边距即为 horizontalMargin
        layout.edgeMargins = UIEdgeInsets(horizontal: Metrics.horizontalMargin * 2.0)
        
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
    /// 模块对应的网格条目
    private func makeCellItems() -> [TPCollectionCellItem] {
        var cellItems = [TPCollectionCellItem]()
        for module in group.availableModules {
            let cellItem = WSPluginModuleCollectionCellItem()
            cellItem.imageName = module.iconName
            cellItem.title = module.displayName
            /// 数目只在进入画廊的模块上展示，表示可选组件的个数
            cellItem.count = module.pickerStyle == .gallery ? module.types.count : 0
            cellItem.didSelectHandler = { [weak self] in
                self?.didSelectModule?(module)
            }
            
            cellItems.append(cellItem)
        }
        
        return cellItems
    }
}
