//
//  WSCalendarEventRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

// MARK: - 数据条目

/// 日历事项列表中的单个事项数据。作为点击回调的数据条目传给交互器。
class WSCalendarEventRowItem: NSObject, WSPluginDataItem {

    /// 事项标识
    let identifier: String

    /// 事项名称
    let title: String

    /// 时间说明，作为副标题展示
    let timeText: String?

    /// 事项颜色
    let color: UIColor

    /// 是否已完成
    let isCompleted: Bool

    /// 原始事项，点击时据此打开详情；预览数据为空
    let event: CalendarEvent?

    /// 由日历事项生成展示数据。跨天事项建议传入对应日期的 timeText
    init(event: CalendarEvent, timeText: String? = nil) {
        self.identifier = event.identifier
        self.title = event.title ?? resGetString("Untitled")
        self.timeText = timeText ?? WSCalendarEventRowItem.defaultTimeText(for: event)
        self.color = event.color
        self.isCompleted = event.isCompleted
        self.event = event
        super.init()
    }

    /// 预览数据：不关联真实事项
    init(identifier: String, title: String, timeText: String?, color: UIColor,
         isCompleted: Bool = false) {
        self.identifier = identifier
        self.title = title
        self.timeText = timeText
        self.color = color
        self.isCompleted = isCompleted
        self.event = nil
        super.init()
    }

    private static func defaultTimeText(for event: CalendarEvent) -> String {
        guard event.isAllDay else {
            return "\(event.startDate.timeString) - \(event.endDate.timeString)"
        }

        return resGetString("All day")
    }
}

// MARK: - 行视图

/// 日历事项的默认行视图。
///
/// 内容由 `TPColorInfoView` 承载：左侧为事项颜色竖条，右侧为事项名称与时间；
/// 没有对应事项的行展示骨架。竖条尺寸、间距等配置与 `WSTodoFilterRowView` 保持一致。
class WSCalendarEventRowView: WSRowView {

    /// 布局尺寸
    private enum Metrics {

        /// 内容与行边缘的间距
        static let contentInsets = UIEdgeInsets(top: 4.0, left: 8.0, bottom: 4.0, right: 8.0)

        /// 按下高亮的圆角
        static let cornerRadius: CGFloat = 10.0

        /// 名称字号
        static let titleFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)

        /// 时间字号
        static let subtitleFont = UIFont.systemFont(ofSize: 12.0)

        /// 名称与时间的间距
        static let subtitleTopMargin: CGFloat = 2.0

        /// 颜色竖条尺寸及其与名称的间距。与待办首页过滤器保持一致
        static let colorBarSize = CGSize(width: 6.0, height: 16.0)
        static let colorBarMargins = UIEdgeInsets(left: 2.0, right: 8.0)

        /// 骨架块颜色。组件底色偏亮，骨架块需要更明显的对比
        static let skeletonColor = Color(light: 0x000000, 0.12, dark: 0xFFFFFF, 0.22)
    }

    /// 当前展示的事项
    private(set) var dataItem: WSCalendarEventRowItem?

    /// 点击行的回调
    var didSelectEventHandler: ((WSCalendarEventRowItem) -> Void)?

    /// 内容与行边缘的间距
    var contentInsets: UIEdgeInsets = Metrics.contentInsets {
        didSet {
            setNeedsLayout()
        }
    }

    /// 颜色竖条 + 名称 + 时间
    let contentView = TPColorInfoView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentCornerRadius = Metrics.cornerRadius

        contentView.titleConfig = .withFont(Metrics.titleFont,
                                             textColor: .label,
                                             adjustsFontSizeToFitWidth: true,
                                             minimumScaleFactor: 0.8)
        contentView.subtitleConfig = .withFont(Metrics.subtitleFont,
                                                textColor: .secondaryLabel,
                                                adjustsFontSizeToFitWidth: true,
                                                minimumScaleFactor: 0.8)
        contentView.subtitleTopMargin = Metrics.subtitleTopMargin

        /// 颜色竖条不参与骨架，名称与时间以胶囊块占位
        contentView.colorView.isSkeletonExcluded = true
        contentView.titleLabel.isSkeletonable = true
        contentView.titleLabel.skeletonShape = .capsule
        contentView.titleLabel.skeletonWidthRatio = 0.5
        contentView.subtitleLabel.isSkeletonable = true
        contentView.subtitleLabel.skeletonShape = .capsule
        contentView.subtitleLabel.skeletonWidthRatio = 0.3

        var skeletonConfig = Skeleton.config
        skeletonConfig.baseColor = Metrics.skeletonColor
        self.skeletonConfig = skeletonConfig

        addSubview(contentView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()

        let frame = bounds.inset(by: contentInsets)
        guard frame.width > 0.0, frame.height > 0.0 else {
            return
        }

        contentView.frame = frame
    }

    /// 颜色配置：竖条尺寸与间距固定，颜色随事项变化
    private func updateColorConfig() {
        let config = TPColorAccessoryConfig()
        config.color = dataItem?.color
        config.size = Metrics.colorBarSize
        config.margins = Metrics.colorBarMargins
        contentView.colorConfig = config
    }

    // MARK: - 渲染
    /// 内容视图按通用数据类型刷新行
    func update(with dataItem: WSPluginDataItem?) {
        update(withEvent: dataItem as? WSCalendarEventRowItem)
    }

    /// 更新展示的事项。传 nil 时清空内容并展示骨架
    func update(withEvent dataItem: WSCalendarEventRowItem?) {
        self.dataItem = dataItem
        updateColorConfig()

        guard let dataItem = dataItem else {
            contentView.title = nil
            contentView.subtitle = nil

            /// 骨架态保留名称与时间一行高度，Skeleton 才能生成文本占位块
            contentView.titleMinimumHeight = ceil(contentView.titleConfig.font.lineHeight)
            contentView.subtitleMinimumHeight = ceil(contentView.subtitleConfig.font.lineHeight)

            setNeedsLayout()
            layoutIfNeeded()
            sk.show(config: skeletonConfig)
            return
        }

        sk.hide()
        contentView.titleMinimumHeight = 0.0
        contentView.subtitleMinimumHeight = 0.0
        contentView.titleConfig = .withFont(Metrics.titleFont,
                                             textColor: dataItem.isCompleted ? .secondaryLabel : .label,
                                             adjustsFontSizeToFitWidth: true,
                                             minimumScaleFactor: 0.8)
        contentView.title = dataItem.title
        contentView.subtitle = dataItem.timeText
        setNeedsLayout()
    }

    // MARK: - 交互
    /// 点击行。没有对应事项时（空白行）不响应
    override func didSelectRow() {
        guard let dataItem = dataItem else {
            return
        }

        didSelectEventHandler?(dataItem)
    }
}
