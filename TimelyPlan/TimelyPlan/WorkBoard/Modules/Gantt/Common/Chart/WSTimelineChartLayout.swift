//
//  WSTimelineChartLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

/// 甘特图组件的行布局：每行占满时间轴宽度，纵向按行高排列
final class WSTimelineChartLayout: UICollectionViewLayout {

    /// 时间刻度
    var timeScale: GanttTimeScale

    /// 事项
    var events: [GanttEvent] = []

    /// 行高
    var rowHeight: CGFloat = WSTimelineChartConfig.rowHeight

    private var cachedAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]

    /// 时间轴内容宽度
    private(set) var contentWidth: CGFloat = 0.0

    /// 内容高度
    private(set) var contentHeight: CGFloat = 0.0

    init(timeScale: GanttTimeScale) {
        self.timeScale = timeScale
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 铺满可视区域所需的最小行数，由甘特图按可视高度设置
    var minimumItemCount = 0

    /// 行数。没有事项时填充占位行铺满可视区域，避免空白页
    var numberOfItems: Int {
        return max(events.count, minimumItemCount)
    }

    override func prepare() {
        super.prepare()
        cachedAttributes.removeAll()

        contentWidth = WSTimelineChartGeometry.contentWidth(timeScale: timeScale)
        contentHeight = CGFloat(numberOfItems) * rowHeight

        for index in 0..<numberOfItems {
            let indexPath = IndexPath(item: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: 0.0,
                                      y: CGFloat(index) * rowHeight,
                                      width: contentWidth,
                                      height: rowHeight)
            cachedAttributes[indexPath] = attributes
        }
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttributes.values.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath]
    }

    // MARK: - 事项

    /// 指定行的序号对应的事项（占位行为 nil）
    func event(at index: Int) -> GanttEvent? {
        guard index >= 0, index < events.count else { return nil }
        return events[index]
    }

    /// 指定日期对应的时间轴 X 坐标
    func xPosition(for date: Date) -> CGFloat {
        return WSTimelineChartGeometry.xPosition(for: date, timeScale: timeScale)
    }

    /// 指定 X 坐标对应的日期
    func date(forX x: CGFloat) -> Date {
        return WSTimelineChartGeometry.date(forX: x, timeScale: timeScale)
    }

    /// 事项的甘特条宽度
    func width(from startDate: Date, to endDate: Date) -> CGFloat {
        let startX = xPosition(for: startDate)
        let endX = xPosition(for: endDate)
        return max(endX - startX, 2.0)
    }
}
