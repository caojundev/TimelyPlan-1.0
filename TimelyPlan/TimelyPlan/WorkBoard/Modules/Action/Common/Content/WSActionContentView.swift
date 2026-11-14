//
//  WSActionContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/14.
//

import Foundation
import UIKit

// MARK: - 内容视图基类

/// 动作内容视图基类，列表与网格共用。
///
/// 顶部统一展示动作图标与名称，下方按最大展示条数均分排列动作行；
/// 子类只负责行列数、间距与行外观。
class WSActionContentView: WSRowListView {

    /// 布局尺寸
    private enum Metrics {

        /// 头部高度
        static let headerHeight: CGFloat = 32.0

        /// 头部与行列表的间距
        static let headerSpacing: CGFloat = 4.0
        
        /// 头部内容间距
        static let headerPadding = UIEdgeInsets(horizontal: 8.0, vertical: 2.0)
        
        /// 图标高度比例
        static let headerIconHeightRatio = 0.8
    }

    /// 最大展示条数，用于计算行列尺寸
    let maximumItemCount: Int

    /// 顶部图标信息视图
    private let headerView = WSIconInfoView()

    init(maximumItemCount: Int) {
        self.maximumItemCount = max(maximumItemCount, 1)
        super.init(frame: .zero)
        headerView.padding = Metrics.headerPadding
        headerView.iconHeightRatio = Metrics.headerIconHeightRatio
        headerView.iconInfoSpacing = 6.0
        headerView.update(icon: TPIcon(name: "arrow_up_24"),
                          iconForeColor: .white,
                          iconBackColor: .primary,
                          title: resGetString("Actions"),
                          subtitle: nil)
        addSubview(headerView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return WSActionRowView()
    }

    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        guard let rowView = rowView as? WSActionRowView else {
            return
        }

        rowView.didSelectHandler = { [weak self, weak rowView] in
            guard let self = self, let action = rowView?.action else {
                return
            }

            self.interactor?.performAction(with: action)
        }
    }

    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()

        headerView.isHidden = isHeaderHidden
        guard !headerView.isHidden else {
            return
        }

        headerView.frame = headerLayoutFrame(in: layoutFrame())
    }

    /// 没有动作时隐藏头部，把整个组件让给空白视图
    private var isHeaderHidden: Bool {
        return numberOfItems == 0
    }

    private func headerLayoutFrame(in layoutFrame: CGRect) -> CGRect {
        return CGRect(x: layoutFrame.minX,
                      y: layoutFrame.minY,
                      width: layoutFrame.width,
                      height: min(Metrics.headerHeight, layoutFrame.height))
    }

    /// 最大行数，行高按该数目均分
    private var maximumRowCount: Int {
        let columns = max(columnCount, 1)
        return max(Int(ceil(Double(maximumItemCount) / Double(columns))), 1)
    }

    /// 行区域位于头部下方
    override var rowsLayoutFrame: CGRect {
        let layoutFrame = layoutFrame()
        guard !isHeaderHidden else {
            return layoutFrame
        }

        let headerFrame = headerLayoutFrame(in: layoutFrame)
        let top = headerFrame.maxY + Metrics.headerSpacing
        return CGRect(x: layoutFrame.minX,
                      y: top,
                      width: layoutFrame.width,
                      height: max(layoutFrame.maxY - top, 0.0))
    }

    override func itemLayoutFrame(at index: Int) -> CGRect {
        let layoutFrame = rowsLayoutFrame
        let columns = max(columnCount, 1)
        let rows = maximumRowCount
        let itemWidth = max((layoutFrame.width - columnSpacing * CGFloat(columns - 1)) / CGFloat(columns), 0.0)
        let itemHeight = max((layoutFrame.height - rowSpacing * CGFloat(rows - 1)) / CGFloat(rows), 0.0)
        let column = index % columns
        let row = index / columns

        return CGRect(x: layoutFrame.minX + CGFloat(column) * (itemWidth + columnSpacing),
                      y: layoutFrame.minY + CGFloat(row) * (itemHeight + rowSpacing),
                      width: itemWidth,
                      height: itemHeight)
    }

    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        /// 行数取动作数与最大展示条数的较小值，先更新再让基类补齐行视图
        let actions = (dataItem as? WSActionListDataItem)?.actions ?? []
        let displayedCount = min(actions.count, maximumItemCount)
        let columns = max(columnCount, 1)
        rowCount = displayedCount > 0 ? Int(ceil(Double(displayedCount) / Double(columns))) : 0
        super.update(with: dataItem)

        for (index, rowView) in rowViews.enumerated() {
            (rowView as? WSActionRowView)?.update(with: actions[safe: index])
        }
    }
}
