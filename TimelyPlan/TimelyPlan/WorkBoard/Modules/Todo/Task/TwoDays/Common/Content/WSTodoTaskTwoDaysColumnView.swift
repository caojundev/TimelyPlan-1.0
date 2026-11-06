//
//  WSTodoTaskTwoDaysColumnView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 单天任务列

/// 今明两天中的单天任务列。
///
/// 顶部为「日期 + 任务数」头部，下方使用 `WSMoreRowListView` 展示任务，
/// 超出展示条数时在列底部展示更多入口。
class WSTodoTaskTwoDaysColumnView: WSMoreRowListView {

    /// 点击任务
    var didSelectTaskHandler: ((WSTodoTaskItem) -> Void)?

    /// 点击完成状态
    var didClickCheckboxHandler: ((WSTodoTaskItem) -> Void)?

    /// 每列最多展示的任务数目
    private let maximumRowCount: Int

    /// 列头高度及与任务列表的间距
    private let headerHeight: CGFloat = 18.0
    private let headerSpacing: CGFloat = 4.0

    /// 列头
    private let headerView = WSInfoTextCountHeaderView()

    init(maximumRowCount: Int) {
        self.maximumRowCount = max(maximumRowCount, 1)
        super.init(frame: .zero)

        columnCount = 1
        rowSpacing = 2.0
        padding = .zero

        addSubview(headerView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据
    /// 更新列标题与任务
    func update(title: String?, items: [WSTodoTaskTwoDaysItem]) {
        headerView.update(title: title, count: items.count)

        /// 行数固定为最大展示行数，任务不足时保留空槽位，保证行高一致
        rowCount = items.isEmpty ? 0 : maximumRowCount
        update(with: WSTodoTaskTwoDaysColumnDataItem(items: items))
    }

    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        let items = (dataItem as? WSTodoTaskTwoDaysColumnDataItem)?.items ?? []
        totalItemCount = items.count

        for (index, rowView) in rowViews.enumerated() {
            guard let rowView = rowView as? WSTodoTaskRowView else {
                continue
            }

            let item = items[safe: index]
            rowView.update(with: item?.taskItem, color: item?.color ?? .primary)
        }
    }

    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return WSTodoTaskRowView()
    }

    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        guard let rowView = rowView as? WSTodoTaskRowView else {
            return
        }

        rowView.padding = UIEdgeInsets(left: 2.0, right: 2.0)
        rowView.didSelectTaskHandler = { [weak self] dataItem in
            self?.didSelectTaskHandler?(dataItem)
        }
        rowView.didClickCheckboxHandler = { [weak self] dataItem in
            self?.didClickCheckboxHandler?(dataItem)
        }
    }

    // MARK: - 布局
    /// 任务列表让出顶部列头的高度
    override var rowsLayoutFrame: CGRect {
        var frame = super.rowsLayoutFrame
        let headerOffset = headerHeight + headerSpacing
        frame.origin.y += headerOffset
        frame.size.height = max(frame.height - headerOffset, 0.0)
        return frame
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        headerView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: headerHeight)
    }
}
