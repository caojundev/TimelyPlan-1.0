//
//  WSTodoListTasksContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 待办自选清单任务的内容视图，各尺寸列表与网格共用。
///
/// 头部展示所选清单的图标、名称与未完成任务数目，下方按布局配置展示未完成任务：
/// 列表为单列排列，网格为多列卡片排列。
class WSTodoListTasksContentView: WSIconInfoTextValueContentView {
    
    // MARK: - 配置
    /// 布局配置
    struct LayoutConfiguration {
        
        /// 最多展示的任务数目
        let itemCount: Int
        
        /// 列数，1 为列表
        let columnCount: Int
        
        /// 行间距
        let rowSpacing: CGFloat
        
        /// 列间距
        let columnSpacing: CGFloat
        
        /// 行的卡片圆角，0 表示沿用行视图的默认值
        let cornerRadius: CGFloat
        
        /// 行的卡片底色，nil 表示不展示底色
        let backColor: UIColor?
        
        /// 行的卡片按下底色，nil 表示沿用行视图的默认值
        let highlightedBackColor: UIColor?
        
        /// 行内容与行边缘的间距
        let rowPadding: UIEdgeInsets
        
        /// 列表：单列纵向排列，行不展示底色
        static func list(itemCount: Int) -> LayoutConfiguration {
            return LayoutConfiguration(itemCount: itemCount,
                                       columnCount: 1,
                                       rowSpacing: 2.0,
                                       columnSpacing: 0.0,
                                       cornerRadius: 0.0,
                                       backColor: nil,
                                       highlightedBackColor: nil,
                                       rowPadding: UIEdgeInsets(left: 2.0, right: 2.0))
        }
        
        /// 网格：多列卡片排列
        static func grid(itemCount: Int, columnCount: Int) -> LayoutConfiguration {
            return LayoutConfiguration(itemCount: itemCount,
                                       columnCount: columnCount,
                                       rowSpacing: 8.0,
                                       columnSpacing: 8.0,
                                       cornerRadius: 12.0,
                                       backColor: Color(light: 0x000000, 0.05, dark: 0xFFFFFF, 0.10),
                                       highlightedBackColor: Color(light: 0x000000, 0.10, dark: 0xFFFFFF, 0.20),
                                       rowPadding: UIEdgeInsets(top: 2.0, left: 8.0, bottom: 2.0, right: 8.0))
        }
    }
    
    /// 未完成任务列表
    private let listView: WSTodoListTasksRowListView
    
    init(layoutConfiguration: LayoutConfiguration) {
        let columnCount = max(layoutConfiguration.columnCount, 1)
        let itemCount = max(layoutConfiguration.itemCount, 1)
        let rowCount = Int(ceil(Double(itemCount) / Double(columnCount)))
        let appearance = WSTodoListTasksRowListView.Appearance(rowPadding: layoutConfiguration.rowPadding,
                                                               cornerRadius: layoutConfiguration.cornerRadius,
                                                               backColor: layoutConfiguration.backColor,
                                                               highlightedBackColor: layoutConfiguration.highlightedBackColor)
        self.listView = WSTodoListTasksRowListView(maximumRowCount: rowCount, appearance: appearance)
        
        super.init(frame: .zero)
        
        listView.columnCount = columnCount
        listView.rowSpacing = layoutConfiguration.rowSpacing
        listView.columnSpacing = layoutConfiguration.columnSpacing
        addSubview(listView)
        
        listView.didSelectTaskHandler = { [weak self] dataItem in
            self?.interactor?.performAction(with: dataItem)
        }
        listView.didClickCheckboxHandler = { [weak self] dataItem in
            (self?.interactor as? WSTodoTaskContentInteractor)?.clickCheckbox(for: dataItem)
        }
        listView.didSelectMoreHandler = { [weak self] in
            (self?.interactor as? WSTodoListTasksContentInteractor)?.selectMore()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 数据
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let dataItem = dataItem as? WSTodoListTasksDataItem
        updateHeader(title: dataItem?.listItem.title,
                     icon: dataItem?.listItem.icon,
                     iconBackColor: dataItem?.listItem.color ?? .primary,
                     count: dataItem?.taskCount ?? 0)
        
        /// 没有任务时隐藏列表，避免展示列表内部的空白占位
        listView.isHidden = dataItem?.items.isEmpty ?? true
        listView.update(items: dataItem?.items ?? [])
    }
    
    // MARK: - 布局
    override func layoutContent(in frame: CGRect) {
        guard frame.width > 0.0, frame.height > 0.0 else {
            return
        }
        
        listView.frame = frame
    }
}
