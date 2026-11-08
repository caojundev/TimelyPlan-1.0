//
//  WSCalendarTwoDaysColumnView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

// MARK: - 单天事项列

/// 今明两天中的单天事项列。
///
/// 在 `WSMoreRowListView` 的基础上增加「日期 + 事项数」列头，
/// 事项列表让出列头高度后由基类排布，超出展示条数时最后一行让给「更多」入口；
/// 点击事项行以外的区域打开该天的事项列表。
class WSCalendarTwoDaysColumnView: WSMoreRowListView {

    /// 布局尺寸
    private enum Metrics {

        /// 列头高度及其与列表的间距
        static let headerHeight: CGFloat = 18.0
        static let headerSpacing: CGFloat = 4.0

        /// 事项行间距
        static let rowSpacing: CGFloat = 2.0

        /// 事项行高度上限，避免事项较少时行被拉得过高
        static let maximumRowHeight: CGFloat = 44.0

        /// 行内容的内边距
        static let rowContentInsets = UIEdgeInsets(horizontal: 4.0, vertical: 2.0)

        /// 行详情展示时间与来源
        static let detailOption: CalendarEventDetailOption = .all
    }

    /// 最多展示的事项数目
    private let maximumRowCount: Int

    /// 列头：日期与事项数
    private let headerView = WSInfoTextCountHeaderView()

    /// 当前展示的日期，点击列内空白或「更多」时据此打开事项列表
    private(set) var date: Date?

    /// 点击事项
    var didSelectEventHandler: ((WSCalendarEventRowItem) -> Void)?

    /// 点击事项行以外的区域
    var didTapHandler: (() -> Void)?

    /// 列内点击手势
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(clickColumn))
        gesture.delegate = self
        return gesture
    }()

    init(maximumRowCount: Int) {
        self.maximumRowCount = max(maximumRowCount, 1)
        super.init(frame: .zero)

        columnCount = 1
        rowSpacing = Metrics.rowSpacing
        padding = .zero

        addSubview(headerView)
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据
    /// 更新列头与事项。列头展示相对日期与星期；只展示有数据的事项行，超出展示条数时最后一行让给「更多」入口
    func update(date: Date?, events: [CalendarEvent]) {
        self.date = date

        let items = events.map { event in
            return WSCalendarEventRowItem(event: event,
                                          date: date,
                                          detailOption: Metrics.detailOption)
        }
        headerView.update(title: headerTitle(for: date), count: items.count)

        rowCount = min(items.count, maximumRowCount)
        reloadData()

        totalItemCount = items.count
        for (index, rowView) in rowViews.enumerated() {
            guard let rowView = rowView as? WSCalendarEventRowView,
                  let item = items[safe: index] else {
                continue
            }

            rowView.update(with: item)
        }
    }

    // MARK: - 辅助
    /// 列头文案：今天 / 明天 + 星期，与其它日期标题的格式保持一致
    private func headerTitle(for date: Date?) -> String? {
        return date?.yearMonthDayWeekdaySymbolString(style: .short,
                                                     omitYear: true,
                                                     showRelativeDate: true)
    }

    // MARK: - 空白视图
    /// 单天没有事项时在列头下方展示空白提示
    override func makeEmptyView() -> WSPluginEmptyPlaceholderView {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "calendar"
        configuration.title = resGetString("No Events")
        return WSPluginDefaultEmptyPlaceholderView(configuration: configuration)
    }

    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        let rowView = WSCalendarEventRowView()
        rowView.contentInsets = Metrics.rowContentInsets
        return rowView
    }

    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        (rowView as? WSCalendarEventRowView)?.didSelectEventHandler = { [weak self] dataItem in
            self?.didSelectEventHandler?(dataItem)
        }
    }

    // MARK: - 布局
    /// 事项列表让出顶部列头的高度
    override var rowsLayoutFrame: CGRect {
        var frame = super.rowsLayoutFrame
        let headerOffset = Metrics.headerHeight + Metrics.headerSpacing
        frame.origin.y += headerOffset
        frame.size.height = max(frame.height - headerOffset, 0.0)
        return frame
    }

    /// 行高按最大展示条数均分并封顶，事项较少时行不会被拉高，两列的行也能对齐
    override func itemLayoutFrame(at index: Int) -> CGRect {
        let layoutFrame = rowsLayoutFrame
        let slotCount = CGFloat(max(maximumRowCount, 1))
        let slotHeight = max((layoutFrame.height - rowSpacing * (slotCount - 1.0)) / slotCount, 0.0)
        let rowHeight = min(slotHeight, Metrics.maximumRowHeight)

        return CGRect(x: layoutFrame.minX,
                      y: layoutFrame.minY + CGFloat(index) * (rowHeight + rowSpacing),
                      width: layoutFrame.width,
                      height: rowHeight)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        headerView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: Metrics.headerHeight)
    }

    // MARK: - 交互
    @objc private func clickColumn() {
        didTapHandler?()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension WSCalendarTwoDaysColumnView: UIGestureRecognizerDelegate {

    /// 事项行与按钮内的点击由它们自己处理，其余区域才响应打开事项列表
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        var view = touch.view
        while let current = view, current !== self {
            if current is WSRowView || current is UIControl {
                return false
            }

            view = current.superview
        }

        return true
    }
}
