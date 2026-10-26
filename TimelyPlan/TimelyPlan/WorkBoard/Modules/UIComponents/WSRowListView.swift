//
//  WSRowListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

// MARK: - 行列表视图

/// 通用行列表视图。
///
/// 把若干行视图按列数等分排列：列数为 1 时是列表，多列时是网格。
/// 子类只需提供行数、列数、间距与每个索引对应的行视图，布局由基类统一处理；
/// 行视图按需创建并缓存，数量不变时不会重复创建，适合固定条数的组件内容。
class WSRowListView: WSPluginContentView {
    
    // MARK: - 子类配置
    /// 行数
    var rowCount: Int = 0 {
        didSet {
            guard rowCount != oldValue else {
                return
            }
            
            setNeedsLayout()
        }
    }
    
    /// 每行个数
    var columnCount: Int = 1 {
        didSet {
            guard columnCount != oldValue else {
                return
            }
            
            setNeedsLayout()
        }
    }
    
    /// 行视图数量，由行数与列数计算
    var numberOfItems: Int {
        return max(rowCount, 0) * max(columnCount, 0)
    }
    
    /// 行间距
    var rowSpacing: CGFloat = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 列间距
    var columnSpacing: CGFloat = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - 行视图
    /// 行视图，顺序与索引一致。子类在 `update(with:)` 中按索引绑定数据
    private(set) var rowViews: [WSRowView] = []
    
    /// 创建索引对应的行视图，只在行视图缺失时调用一次，子类必须重写
    func makeRowView(at index: Int) -> WSRowView {
        fatalError("Subclass must override makeRowView(at:)")
    }
    
    /// 行视图加入层级后调用，子类可在此统一配置外观与交互
    func didAddRowView(_ rowView: WSRowView, at index: Int) {
        
    }
    
    /// 按当前行列数重建行视图并重新布局
    func reloadData() {
        updateRowViewsIfNeeded()
        setNeedsLayout()
    }
    
    // MARK: - 数据
    override func update(with dataItem: WSPluginDataItem?) {
        /// 数据可能在首次布局前下发，先补齐行视图再交给子类绑定
        updateRowViewsIfNeeded()
        super.update(with: dataItem)
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateRowViewsIfNeeded()
        layoutRowViews()
    }
    
    /// 按行列数补齐或移除行视图，保留已有的行视图避免重复创建
    private func updateRowViewsIfNeeded() {
        let count = numberOfItems
        guard rowViews.count != count else {
            return
        }
        
        if rowViews.count > count {
            rowViews[count...].forEach { $0.removeFromSuperview() }
            rowViews.removeSubrange(count...)
            return
        }
        
        for index in rowViews.count..<count {
            let rowView = makeRowView(at: index)
            rowViews.append(rowView)
            addSubview(rowView)
            didAddRowView(rowView, at: index)
        }
    }
    
    /// 按列数等分可用区域，剩余空间均分给行与列
    private func layoutRowViews() {
        guard !rowViews.isEmpty else {
            return
        }
        
        let layoutFrame = layoutFrame()
        guard layoutFrame.width > 0.0, layoutFrame.height > 0.0 else {
            return
        }
        
        let columns = max(columnCount, 1)
        let rows = max(rowCount, 1)
        
        let itemWidth = max((layoutFrame.width - columnSpacing * CGFloat(columns - 1)) / CGFloat(columns), 0.0)
        let itemHeight = max((layoutFrame.height - rowSpacing * CGFloat(rows - 1)) / CGFloat(rows), 0.0)
        
        for (index, rowView) in rowViews.enumerated() {
            let column = index % columns
            let row = index / columns
            
            rowView.size = CGSize(width: itemWidth, height: itemHeight)
            rowView.left = layoutFrame.minX + CGFloat(column) * (itemWidth + columnSpacing)
            rowView.top = layoutFrame.minY + CGFloat(row) * (itemHeight + rowSpacing)
        }
    }
}
