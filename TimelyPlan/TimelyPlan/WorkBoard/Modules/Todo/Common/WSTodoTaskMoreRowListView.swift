//
//  WSTodoTaskMoreRowListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 带更多入口的任务列表

/// 待办任务列表视图，固定展示条数，超出时最后一行让给更多入口。
///
/// 只负责任务行与更多入口，不含列头；需要列头的场景由此派生并预留列头高度。
class WSTodoTaskMoreRowListView: WSMoreRowListView {

    /// 点击任务
    var didSelectTaskHandler: ((WSTodoTaskItem) -> Void)?

    /// 点击完成状态
    var didClickCheckboxHandler: ((WSTodoTaskItem) -> Void)?

    /// 最多展示的任务数目
    private let maximumRowCount: Int

    init(maximumRowCount: Int) {
        self.maximumRowCount = max(maximumRowCount, 1)
        super.init(frame: .zero)

        columnCount = 1
        rowSpacing = 2.0
        padding = .zero
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据
    /// 更新任务列表。行数固定为最大展示行数，任务不足时保留空槽位，保证行高一致
    func update(items: [WSTodoTaskRowItem]) {
        rowCount = items.isEmpty ? 0 : maximumRowCount
        reloadData()

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
}
