//
//  WSCalendarTwoDaysContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 日历今明两天组件的内容视图。
///
/// 顶部为图标标题与事项总数，下方按今天、明天分为两列事项列表，中间以分隔线隔开；
/// 每列自带日期列头与「更多」入口。
class WSCalendarTwoDaysContentView: WSIconInfoTextValueContentView {

    /// 布局尺寸
    private enum Metrics {

        /// 内容与组件边缘的间距
        static let contentInsets = UIEdgeInsets(value: 10.0)

        /// 两列之间的间距
        static let columnSpacing: CGFloat = 8.0

        /// 分隔线宽度
        static let dividerWidth: CGFloat = 1.0

        /// 分隔线上下内缩
        static let dividerVerticalInset: CGFloat = 2.0
    }

    /// 标题图标
    private let titleIcon = TPIcon(name: "calendar_24")

    /// 标题与图标背景色：日历红
    private let titleColor = Color(0xE8362C)

    /// 今天、明天的事项列
    private let todayColumnView: WSCalendarTwoDaysColumnView
    private let tomorrowColumnView: WSCalendarTwoDaysColumnView

    /// 列分隔线
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color(light: 0x000000, 0.08, dark: 0xFFFFFF, 0.12)
        return view
    }()

    init(maximumRowCount: Int) {
        self.todayColumnView = WSCalendarTwoDaysColumnView(maximumRowCount: maximumRowCount)
        self.tomorrowColumnView = WSCalendarTwoDaysColumnView(maximumRowCount: maximumRowCount)
        super.init(frame: .zero)

        self.contentInsets = Metrics.contentInsets

        addSubview(todayColumnView)
        addSubview(dividerView)
        addSubview(tomorrowColumnView)

        let selectHandler: (WSCalendarEventRowItem) -> Void = { [weak self] dataItem in
            self?.interactor?.performAction(with: dataItem)
        }
        for columnView in [todayColumnView, tomorrowColumnView] {
            columnView.didSelectEventHandler = selectHandler

            /// 点击事项行以外的区域打开该列日期的事项列表
            columnView.didTapHandler = { [weak self, weak columnView] in
                self?.openEventList(of: columnView)
            }

            columnView.didSelectMoreHandler = { [weak self, weak columnView] in
                self?.openEventList(of: columnView)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        guard let dataItem = dataItem as? WSCalendarTwoDaysDataItem else {
            updateHeader(title: resGetString("Today & Tomorrow"),
                         icon: titleIcon,
                         iconBackColor: titleColor,
                         count: 0)
            todayColumnView.update(date: nil, events: [])
            tomorrowColumnView.update(date: nil, events: [])
            return
        }

        updateHeader(title: resGetString("Today & Tomorrow"),
                     icon: titleIcon,
                     iconBackColor: titleColor,
                     count: dataItem.totalCount)
        todayColumnView.update(date: dataItem.today.date, events: dataItem.today.events)
        tomorrowColumnView.update(date: dataItem.tomorrow.date, events: dataItem.tomorrow.events)
    }

    // MARK: - 布局
    override func layoutContent(in frame: CGRect) {
        guard frame.width > 0.0, frame.height > 0.0 else {
            return
        }

        let columnWidth = max((frame.width - Metrics.dividerWidth - Metrics.columnSpacing * 2.0) / 2.0, 0.0)
        todayColumnView.frame = CGRect(x: frame.minX,
                                       y: frame.minY,
                                       width: columnWidth,
                                       height: frame.height)

        dividerView.frame = CGRect(x: todayColumnView.right + Metrics.columnSpacing,
                                   y: frame.minY + Metrics.dividerVerticalInset,
                                   width: Metrics.dividerWidth,
                                   height: max(frame.height - Metrics.dividerVerticalInset * 2.0, 0.0))

        tomorrowColumnView.frame = CGRect(x: dividerView.right + Metrics.columnSpacing,
                                          y: frame.minY,
                                          width: columnWidth,
                                          height: frame.height)
    }

    // MARK: - 交互
    /// 点击「更多」或列内空白：打开该列日期的事项列表
    private func openEventList(of columnView: WSCalendarTwoDaysColumnView?) {
        guard let date = columnView?.date else {
            return
        }

        (interactor as? WSCalendarEventContentInteractor)?.openEventList(on: date)
    }
}
