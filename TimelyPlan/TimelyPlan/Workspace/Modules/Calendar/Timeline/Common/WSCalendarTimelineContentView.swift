//
//  WSCalendarTimelineContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation
import UIKit

/// 时间线插件的内容视图基类。
///
/// 统一时间线的背景、数据绑定与点击交互，各尺寸只需在子类中排布自身布局。
class WSCalendarTimelineContentView: WSPluginContentView {

    /// 时间线
    let timelineView = WSCalendarTimelineView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = timelineView.appearance.backgroundColor
        isOpaque = true

        /// 点击事项打开详情
        timelineView.didSelectEventHandler = { [weak self] event in
            self?.interactor?.performAction(with: WSCalendarEventRowItem(event: event))
        }

        /// 点击空白位置打开当天事项列表
        timelineView.didTapEmptyHandler = { [weak self] _ in
            guard let self = self else {
                return
            }

            (self.interactor as? WSCalendarEventContentInteractor)?.openEventList(on: Date())
        }

        addSubview(timelineView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据

    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        guard let dataItem = dataItem as? WSCalendarTimelineDataItem else {
            updateDate(nil)
            timelineView.date = nil
            timelineView.events = []
            return
        }

        updateDate(dataItem.date)
        timelineView.startHour = dataItem.startHour
        timelineView.endHour = dataItem.endHour
        timelineView.date = dataItem.date
        timelineView.events = dataItem.events
    }

    /// 更新日期信息，由各尺寸按自身布局展示
    func updateDate(_ date: Date?) {

    }
}
