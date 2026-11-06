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
/// 在 `WSTodoTaskMoreRowListView` 的基础上增加「日期 + 任务数」列头，
/// 任务列表让出列头高度后由基类排布。
class WSTodoTaskTwoDaysColumnView: WSTodoTaskMoreRowListView {

    /// 列头高度及与任务列表的间距
    private enum Metrics {

        static let headerHeight: CGFloat = 18.0
        static let headerSpacing: CGFloat = 4.0
    }

    /// 列头
    private let headerView = WSInfoTextCountHeaderView()

    override init(maximumRowCount: Int) {
        super.init(maximumRowCount: maximumRowCount)

        addSubview(headerView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据
    /// 更新列标题与任务
    func update(title: String?, items: [WSTodoTaskRowItem]) {
        headerView.update(title: title, count: items.count)
        update(items: items)
    }

    // MARK: - 布局
    /// 任务列表让出顶部列头的高度
    override var rowsLayoutFrame: CGRect {
        var frame = super.rowsLayoutFrame
        let headerOffset = Metrics.headerHeight + Metrics.headerSpacing
        frame.origin.y += headerOffset
        frame.size.height = max(frame.height - headerOffset, 0.0)
        return frame
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        headerView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: Metrics.headerHeight)
    }
}
