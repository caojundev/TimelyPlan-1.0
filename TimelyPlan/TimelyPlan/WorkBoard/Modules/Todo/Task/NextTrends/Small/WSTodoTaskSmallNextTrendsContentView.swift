//
//  WSTodoTaskSmallNextTrendsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 待办·小·接下来七天组件的内容视图。
///
/// 顶部为图标标题与七天任务总数，下方为从后天开始的七天负载柱状图，
/// 底部展示最忙的一天与当天的任务数目。
class WSTodoTaskSmallNextTrendsContentView: WSIconInfoTextValueContentView {

    /// 标题图标与标题颜色
    private let titleIcon = TPIcon(name: "todo_smartlist_upcoming_24")
    private let titleColor: UIColor = Color(0x00A6A6)

    /// 七天负载柱状图与说明
    private let activityView = WSTodoTaskNextTrendsActivityView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(activityView)
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
    }

    // MARK: - 布局
    override func layoutContent(in frame: CGRect) {
        guard frame.width > 0.0, frame.height > 0.0 else {
            return
        }

        activityView.frame = frame
    }
}
