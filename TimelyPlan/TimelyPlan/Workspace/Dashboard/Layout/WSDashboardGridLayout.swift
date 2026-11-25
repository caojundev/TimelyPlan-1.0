//
//  WSDashboardGridLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation
import UIKit

/// 工作台仪表盘布局计算。
///
/// 以小号组件作为网格单元（1x1）：
/// - 小号：1 列 1 行
/// - 中号：整行宽度，1 行高
/// - 大号：整行宽度，2 行高
/// - 自适应：整行宽度，高度由组件按宽度计算
///
/// 行条目数随容器宽度在 2 ~ 6 之间变化且始终为偶数；网格宽度以 `preferredGridWidth` 为基准，
/// 铺满可用宽度的同时不超过 `maximumGridWidth`，内容整体不超过 `maximumContentWidth`，
/// 剩余空间由 `sectionInset` 居中吸收。
class WSDashboardGridLayout {
    
    /// 最小行条目数
    static let minimumItemsCountPerRow: Int = 2
    
    /// 最大行条目数
    static let maximumItemsCountPerRow: Int = 6
    
    /// 组件间距。固定值，不随容器宽度变化
    let interitemSpacing: CGFloat
    
    /// 行间距。固定值，不随容器宽度变化
    let lineSpacing: CGFloat
    
    /// 外部边距。内容与容器边缘的最小距离
    let edgeMargins: UIEdgeInsets
    
    /// 首选网格宽度。行条目数以它为基准推导
    let preferredGridWidth: CGFloat
    
    /// 网格宽度上限。避免超大容器把组件拉得过大
    let maximumGridWidth: CGFloat
    
    /// 内容宽度上限。避免超大容器下内容被继续拉宽
    let maximumContentWidth: CGFloat
    
    /// 容器尺寸。赋值后会在下次取用时重新计算各尺寸。
    var containerSize: CGSize? {
        didSet {
            guard containerSize != oldValue else {
                return
            }
            
            setNeedsLayout()
        }
    }
    
    init(edgeMargins: UIEdgeInsets = UIEdgeInsets(horizontal: 16.0, vertical: 16.0),
         interitemSpacing: CGFloat = 8.0,
         lineSpacing: CGFloat = 8.0,
         preferredGridWidth: CGFloat = 160.0,
         maximumGridWidth: CGFloat = 200.0,
         maximumContentWidth: CGFloat = 680.0) {
        self.edgeMargins = edgeMargins
        self.interitemSpacing = interitemSpacing
        self.lineSpacing = lineSpacing
        self.preferredGridWidth = preferredGridWidth
        self.maximumGridWidth = maximumGridWidth
        self.maximumContentWidth = maximumContentWidth
    }
    
    // MARK: - 布局结果
    /// 实际行条目数。始终为 2 ~ 6 之间的偶数
    var itemsCountPerRow: Int {
        layoutIfNeeded()
        return _itemsCountPerRow
    }
    
    /// 网格单元边长（等于小号组件的宽 / 高）
    var gridWidth: CGFloat {
        layoutIfNeeded()
        return _gridWidth
    }
    
    /// 区块内边距。内容不足整行占满时，剩余空间由左右内边距均分
    var sectionInset: UIEdgeInsets {
        layoutIfNeeded()
        return _sectionInset
    }
    
    /// 整行内容宽度（自适应组件占满整行时的宽度）
    private var contentWidth: CGFloat {
        return calculateContentWidth(gridWidth: gridWidth, itemsCountPerRow: itemsCountPerRow)
    }
    
    /// 容器尺寸变化后重新计算布局
    func updateLayoutIfNeeded(containerSize: CGSize) {
        self.containerSize = containerSize
    }
    
    // MARK: - 布局计算
    private var _itemsCountPerRow: Int = WSDashboardGridLayout.minimumItemsCountPerRow
    
    private var _gridWidth: CGFloat = 0.0
    
    private var _sectionInset: UIEdgeInsets = .zero
    
    /// 是否需要重新计算
    private var shouldLayout: Bool = true
    
    func setNeedsLayout() {
        shouldLayout = true
    }
    
    func layoutIfNeeded() {
        guard shouldLayout else {
            return
        }
        
        shouldLayout = false
        layout()
    }
    
    private func layout() {
        guard let containerSize = containerSize, containerSize.width > 0.0 else {
            _itemsCountPerRow = Self.minimumItemsCountPerRow
            _gridWidth = 0.0
            _sectionInset = edgeMargins
            return
        }
        
        /// 内容宽度不超过上限，超出部分由 sectionInset 居中吸收
        let availableWidth = max(containerSize.width - edgeMargins.horizontalLength, 0.0)
        let usableWidth = min(availableWidth, maximumContentWidth)
        let itemsCountPerRow = calculateItemsCountPerRow(usableWidth: usableWidth)
        let gridWidth = calculateGridWidth(usableWidth: usableWidth, itemsCountPerRow: itemsCountPerRow)
        
        _itemsCountPerRow = itemsCountPerRow
        _gridWidth = gridWidth
        _sectionInset = calculateSectionInset(containerSize: containerSize,
                                              contentWidth: calculateContentWidth(gridWidth: gridWidth,
                                                                                  itemsCountPerRow: itemsCountPerRow))
    }
    
    /// 行条目数：按首选网格宽度能容纳的列数向下取偶，
    /// 保证网格宽度不小于首选宽度；容器过窄时由最小条目数兜底，过宽时由最大条目数收敛。
    private func calculateItemsCountPerRow(usableWidth: CGFloat) -> Int {
        let baseWidth = max(preferredGridWidth, 1.0)
        let fittingCount = Int(((usableWidth + interitemSpacing) / (baseWidth + interitemSpacing)).rounded(.down))
        let clampedCount = min(max(fittingCount, Self.minimumItemsCountPerRow), Self.maximumItemsCountPerRow)
        return clampedCount - clampedCount % 2
    }
    
    /// 网格宽度：优先铺满可用宽度，但不超过最大网格宽度
    private func calculateGridWidth(usableWidth: CGFloat, itemsCountPerRow: Int) -> CGFloat {
        let count = CGFloat(itemsCountPerRow)
        let filledWidth = (usableWidth - (count - 1.0) * interitemSpacing) / count
        return max(min(filledWidth, maximumGridWidth), 0.0)
    }
    
    /// 整行内容宽度
    private func calculateContentWidth(gridWidth: CGFloat, itemsCountPerRow: Int) -> CGFloat {
        let count = CGFloat(itemsCountPerRow)
        return count * gridWidth + (count - 1.0) * interitemSpacing
    }
    
    /// 区块内边距：可用区域中扣除内容宽度后，剩余空间均分到左右两侧
    private func calculateSectionInset(containerSize: CGSize, contentWidth: CGFloat) -> UIEdgeInsets {
        let centeredMargin = max((containerSize.width - edgeMargins.horizontalLength - contentWidth) / 2.0, 0.0)
        return UIEdgeInsets(top: edgeMargins.top,
                            left: edgeMargins.left + centeredMargin,
                            bottom: edgeMargins.bottom,
                            right: edgeMargins.right + centeredMargin)
    }
    
    // MARK: - 条目尺寸
    /// 指定尺寸组件的条目尺寸
    func itemSize(for size: WSPluginSize) -> CGSize {
        let gridWidth = self.gridWidth
        guard gridWidth > 0.0 else {
            return .zero
        }
        
        /// 大号高度：2 个网格单元加中间间距
        let doubleGridWidth = 2.0 * gridWidth + interitemSpacing
        
        switch size {
        case .small:
            return CGSize(width: gridWidth, height: gridWidth)
        case .medium:
            return CGSize(width: contentWidth, height: gridWidth)
        case .large:
            return CGSize(width: contentWidth, height: doubleGridWidth)
        case .flexible:
            /// 缺少插件信息时无法计算高度，按整行宽度与一个网格单元高度返回
            return CGSize(width: contentWidth, height: gridWidth)
        }
    }
    
    /// 指定组件的条目尺寸。尺寸取自注册的组件提供者，
    /// `flexible` 组件的高度按其宽度与组件提供的高度计算对象得出。
    func itemSize(for plugin: WSPlugin) -> CGSize {
        guard plugin.type.size == .flexible else {
            return itemSize(for: plugin.type.size)
        }
        
        let width = contentWidth
        return CGSize(width: width, height: flexibleHeight(for: plugin, width: width))
    }
    
    // MARK: - 自适应高度
    /// 高度计算对象缓存，key 为插件标识。插件配置变化后重建
    private struct HeightCalculator {
        
        let configJSON: String?
        
        let calculator: WSPluginHeightCalculating
    }
    
    private var heightCalculators: [String: HeightCalculator] = [:]
    
    /// flexible 组件缺少高度计算对象时的默认高度，等于一个网格单元
    private var defaultFlexibleHeight: CGFloat {
        return gridWidth
    }
    
    /// flexible 组件算出非正高度时的兜底高度。
    ///
    /// 具体高度由组件自行决定（如分割线只有 30pt），布局只保证条目不会塌陷为 0
    private var minimumFlexibleHeight: CGFloat {
        return 1.0
    }
    
    /// flexible 组件在给定宽度下的高度
    private func flexibleHeight(for plugin: WSPlugin, width: CGFloat) -> CGFloat {
        guard let calculator = heightCalculator(for: plugin) else {
            assert(false, "flexible 尺寸组件需要提供高度计算对象：\(plugin.type.rawValue)")
            return defaultFlexibleHeight
        }
        
        return max(ceil(calculator.height(forWidth: width)), minimumFlexibleHeight)
    }
    
    /// 按插件取回高度计算对象。配置未变化时复用已创建的对象，避免每次布局都重新解析配置
    private func heightCalculator(for plugin: WSPlugin) -> WSPluginHeightCalculating? {
        if let cached = heightCalculators[plugin.identifier], cached.configJSON == plugin.configJSON {
            return cached.calculator
        }
        
        guard let provider = WSPluginRegistry.shared.provider(for: plugin.type),
              let calculator = provider.makeHeightCalculator(plugin: plugin) else {
            heightCalculators[plugin.identifier] = nil
            return nil
        }
        
        heightCalculators[plugin.identifier] = HeightCalculator(configJSON: plugin.configJSON,
                                                                calculator: calculator)
        return calculator
    }
}
