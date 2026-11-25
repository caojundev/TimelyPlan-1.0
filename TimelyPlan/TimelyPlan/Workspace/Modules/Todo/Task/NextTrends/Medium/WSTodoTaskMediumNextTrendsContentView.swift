//
//  WSTodoTaskMediumNextTrendsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 待办·中·接下来七天组件的内容视图。
///
/// 左侧与「小」尺寸一致，展示从后天起七天的负载柱状图与说明；
/// 右侧展示接下来要做的任务，超出展示条数时在底部展示更多入口。
class WSTodoTaskMediumNextTrendsContentView: WSIconInfoTextValueContentView {

    /// 布局尺寸
    private enum Metrics {

        /// 柱状图占内容宽度的比例及其与任务列表的间距
        static let activityWidthRatio: CGFloat = 0.45
        static let listSpacing: CGFloat = 12.0
    }

    /// 标题图标与标题颜色
    private let titleIcon = TPIcon(name: "todo_smartlist_upcoming_24")
    private let titleColor: UIColor = Color(0x00A6A6)

    /// 七天负载柱状图与说明
    private let activityView = WSTodoTaskNextTrendsActivityView()

    /// 接下来要做的任务
    private let listView = WSTodoTaskMoreRowListView(maximumRowCount: WSTodoTaskNextTrendsLayout.mediumRowCount)

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(activityView)
        addSubview(listView)

        listView.didSelectTaskHandler = { [weak self] dataItem in
            self?.interactor?.performAction(with: dataItem)
        }
        listView.didClickCheckboxHandler = { [weak self] dataItem in
            (self?.interactor as? WSTodoTaskContentInteractor)?.clickCheckbox(for: dataItem)
        }
        listView.didSelectMoreHandler = { [weak self] in
            (self?.interactor as? WSTodoTaskNextTrendsContentInteractor)?.selectMore()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        let dataItem = dataItem as? WSTodoTaskNextTrendsDataItem
        updateHeader(title: resGetString("Upcoming"),
                     icon: titleIcon,
                     iconBackColor: titleColor,
                     count: dataItem?.totalCount ?? 0)
        activityView.update(with: dataItem)
        listView.update(items: dataItem?.items ?? [])
    }

    // MARK: - 布局
    override func layoutContent(in frame: CGRect) {
        guard frame.width > 0.0, frame.height > 0.0 else {
            return
        }

        activityView.frame = CGRect(x: frame.minX,
                                    y: frame.minY,
                                    width: frame.width * Metrics.activityWidthRatio,
                                    height: frame.height)
        listView.frame = CGRect(x: activityView.right + Metrics.listSpacing,
                                y: frame.minY,
                                width: max(frame.maxX - activityView.right - Metrics.listSpacing, 0.0),
                                height: frame.height)
    }
}
