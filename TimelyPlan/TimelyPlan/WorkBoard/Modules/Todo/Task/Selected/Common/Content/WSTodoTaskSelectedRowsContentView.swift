//
//  WSTodoTaskSelectedRowsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 行内容视图

/// 待办自选任务的内容视图，各尺寸列表与网格共用。
///
/// 行视图复用四象限任务行，点击任务与点击完成状态的行为也与四象限一致；
/// 列表与网格的差异通过布局配置表达。
class WSTodoTaskSelectedRowsContentView: WSRowListView {

    // MARK: - 配置
    /// 布局配置
    struct LayoutConfiguration {

        /// 内容与组件边缘的间距
        let padding: UIEdgeInsets

        /// 列数，1 为列表
        let columnCount: Int

        /// 行间距
        let rowSpacing: CGFloat

        /// 列间距
        let columnSpacing: CGFloat

        /// 行的卡片圆角，0 表示不展示卡片
        let cornerRadius: CGFloat

        /// 行的卡片底色，nil 表示不展示底色
        let backColor: UIColor?

        /// 行的卡片按下底色，nil 表示沿用行视图的默认值
        let highlightedBackColor: UIColor?

        /// 行内容与行边缘的间距
        let rowPadding: UIEdgeInsets

        /// 列表：单列纵向排列，行不展示底色
        static let list = LayoutConfiguration(padding: UIEdgeInsets(value: 8.0),
                                              columnCount: 1,
                                              rowSpacing: 4.0,
                                              columnSpacing: 0.0,
                                              cornerRadius: 0.0,
                                              backColor: nil,
                                              highlightedBackColor: nil,
                                              rowPadding: UIEdgeInsets(left: 4.0, right: 4.0))

        /// 网格：多列卡片排列
        static func grid(columnCount: Int = 2) -> LayoutConfiguration {
            return LayoutConfiguration(padding: UIEdgeInsets(value: 8.0),
                                       columnCount: columnCount,
                                       rowSpacing: 8.0,
                                       columnSpacing: 8.0,
                                       cornerRadius: 12.0,
                                       backColor: Color(light: 0x000000, 0.05, dark: 0xFFFFFF, 0.10),
                                       highlightedBackColor: Color(light: 0x000000, 0.10, dark: 0xFFFFFF, 0.20),
                                       rowPadding: UIEdgeInsets(top: 2.0, left: 8.0, bottom: 2.0, right: 8.0))
        }
    }

    /// 布局配置
    private let layoutConfiguration: LayoutConfiguration

    init(itemCount: Int, layoutConfiguration: LayoutConfiguration) {
        self.layoutConfiguration = layoutConfiguration
        super.init(frame: .zero)

        let padding = layoutConfiguration.padding
        self.padding = padding

        let itemCount = max(itemCount, 0)
        let columns = min(max(layoutConfiguration.columnCount, 1), max(itemCount, 1))
        self.columnCount = columns
        self.rowCount = itemCount > 0 ? Int(ceil(Double(itemCount) / Double(columns))) : 0
        self.rowSpacing = layoutConfiguration.rowSpacing
        self.columnSpacing = layoutConfiguration.columnSpacing
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return WSQuadrantTaskRowView()
    }

    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        guard let rowView = rowView as? WSQuadrantTaskRowView else {
            return
        }

        rowView.padding = layoutConfiguration.rowPadding

        if layoutConfiguration.cornerRadius > 0.0 {
            rowView.contentCornerRadius = layoutConfiguration.cornerRadius
        }

        rowView.didSelectTaskHandler = { [weak self] dataItem in
            self?.interactor?.performAction(with: dataItem)
        }
        rowView.didClickCheckboxHandler = { [weak self] dataItem in
            (self?.interactor as? WSTodoTaskContentInteractor)?.clickCheckbox(for: dataItem)
        }
    }

    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        let items = (dataItem as? WSTodoTaskSelectedRowsDataItem)?.items ?? []
        for (index, rowView) in rowViews.enumerated() {
            guard let rowView = rowView as? WSQuadrantTaskRowView else {
                continue
            }

            /// 空位传 nil，行视图内部会隐藏内容
            let item = items[safe: index]
            rowView.update(with: item?.rowItem, color: item?.color ?? .primary)

            /// 行视图刷新时会重置底色，有数据时需要重新应用卡片外观
            if item != nil {
                updateCardAppearance(for: rowView)
            }
        }
    }

    /// 行的卡片底色。列表不展示底色，网格展示卡片
    private func updateCardAppearance(for rowView: WSQuadrantTaskRowView) {
        rowView.normalBackColor = layoutConfiguration.backColor ?? .clear

        if let backColor = layoutConfiguration.highlightedBackColor {
            rowView.highlightedBackColor = backColor
        }
    }
}
