//
//  WSCalendarSmallDateContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 两款日期组件共用的配色
enum WSCalendarSmallDateAppearance {
    static let backColor = Color(0x17171A)
    static let textColor = UIColor.white
    static let secondaryTextColor = Color(0x8E8E93)
    static let accentColor = Color(0xE8362C)
}

/// 日历·小·今日日期的共用内容视图。
///
/// 仅使用三个文本图层，样式差异由子类决定字号与排版。
class WSCalendarSmallDateContentView: WSPluginContentView {

    let monthLabel = UILabel()
    let weekdayLabel = UILabel()
    let dayLabel = UILabel()

    private var appliedSize: CGSize = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = WSCalendarSmallDateAppearance.backColor
        isOpaque = true

        for label in [monthLabel, weekdayLabel, dayLabel] {
            label.textColor = WSCalendarSmallDateAppearance.textColor
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            label.baselineAdjustment = .alignCenters
            addSubview(label)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()

        let contentFrame = layoutFrame()
        guard contentFrame.width > 0.0, contentFrame.height > 0.0 else {
            return
        }

        applyFontsIfNeeded(for: contentFrame.size)
        layoutDateLabels(in: contentFrame)
    }

    func fontSizes(for contentSize: CGSize) -> (month: CGFloat, weekday: CGFloat, day: CGFloat) {
        let unit = min(contentSize.width, contentSize.height)
        return (unit * 0.08, unit * 0.10, unit * 0.45)
    }

    func layoutDateLabels(in contentFrame: CGRect) {

    }

    private func applyFontsIfNeeded(for size: CGSize) {
        guard appliedSize != size else {
            return
        }

        appliedSize = size
        let sizes = fontSizes(for: size)
        monthLabel.font = UIFont.systemFont(ofSize: sizes.month, weight: .medium)
        weekdayLabel.font = UIFont.systemFont(ofSize: sizes.weekday, weight: .medium)
        dayLabel.font = UIFont.systemFont(ofSize: sizes.day, weight: .regular)
    }

    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        let dateItem = dataItem as? WSCalendarTodayDateDataItem
        monthLabel.text = dateItem?.monthText
        weekdayLabel.text = dateItem?.weekdayText
        dayLabel.text = dateItem?.dayText
    }
}
