//
//  WSCalendarEventListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历组件通用的事项列表视图。
///
/// 按天分 section：每个 section 一个日期头视图，其下排布当天的事项行；
/// 可用高度不足时截断，并紧接在最后一行之后用「更多 x 个」提示被截断 section 剩余的事项。
/// 子类只需提供分组数、行数、视图工厂与数据绑定；数据变化后调用 `reloadData()`
/// （覆写 `update(with:)` 时调用 `super` 即可）。
/// 布局结果按 `layoutFrame()` 缓存，只有布局区域变化或 `reloadData()` 才重新排布。
class WSCalendarEventListView: WSPluginContentView {

    // MARK: - 布局结果
    private struct HeaderLayout {
        let section: Int
        let frame: CGRect
    }

    private struct RowLayout {
        let indexPath: IndexPath
        let frame: CGRect
    }

    private struct Layout {
        let frame: CGRect
        var headers: [HeaderLayout] = []
        var rows: [RowLayout] = []
        var moreSection: Int?
        var moreCount: Int = 0
        var moreFrame: CGRect?

        var isEmpty: Bool {
            return headers.isEmpty && rows.isEmpty && moreSection == nil
        }
    }

    // MARK: - 尺寸配置
    /// 日期头视图高度，设为 0 时不展示头视图
    var sectionHeaderHeight: CGFloat = 18.0 { didSet { reloadData() } }

    /// 头视图与首行的间距
    var headerRowSpacing: CGFloat = 4.0 { didSet { reloadData() } }

    /// 事项行高度
    var rowHeight: CGFloat = 28.0 { didSet { reloadData() } }

    /// 事项行间距
    var rowSpacing: CGFloat = 2.0 { didSet { reloadData() } }

    /// 相邻两天的间距
    var sectionSpacing: CGFloat = 8.0 { didSet { reloadData() } }

    /// 「更多」入口高度
    var moreEntryHeight: CGFloat = 18.0 { didSet { reloadData() } }

    /// 「更多」入口的左缩进
    var moreLeadingInset: CGFloat = 8.0 { didSet { reloadData() } }

    // MARK: - 子类数据
    /// 天数
    var numberOfSections: Int { return 0 }

    /// 指定天的事项数
    func numberOfRows(in section: Int) -> Int { return 0 }

    /// 头视图文案。默认头视图用该文案展示日期
    func headerTitle(at section: Int) -> String? { return nil }

    // MARK: - 子类视图
    /// 创建头视图，只在 section 首次可见时调用一次
    func makeHeaderView(at section: Int) -> UIView {
        let label = TPLabel()
        label.font = .boldSystemFont(ofSize: 12.0)
        label.textColor = .secondaryLabel
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.edgeInsets = UIEdgeInsets(left: 8.0, right: 8.0)
        return label
    }

    /// 头视图加入层级后调用，用于一次性配置外观
    func didAddHeaderView(_ headerView: UIView, at section: Int) {}

    /// 绑定头视图数据，自定义头视图时一并覆写
    func updateHeaderView(_ headerView: UIView, at section: Int) {
        (headerView as? UILabel)?.text = headerTitle(at: section)
    }

    /// 创建事项行，只在索引首次可见时调用一次。默认使用 `WSCalendarEventRowView`
    func makeRowView(at indexPath: IndexPath) -> WSRowView {
        return WSCalendarEventRowView()
    }

    /// 事项行加入层级后调用，用于一次性配置外观与交互
    func didAddRowView(_ rowView: WSRowView, at indexPath: IndexPath) {}

    /// 绑定事项行数据
    func updateRowView(_ rowView: WSRowView, at indexPath: IndexPath) {}

    /// 「更多」入口展示的数量。默认只统计未展示完的那个 section 剩余的事项
    func moreItemCount(in section: Int, hiddenRowCount: Int) -> Int {
        return hiddenRowCount
    }

    /// 空白视图，无事项时展示
    func makeEmptyView() -> WSPluginEmptyPlaceholderView {
        return WSPluginDefaultEmptyPlaceholderView()
    }

    // MARK: - 交互
    /// 点击「更多」入口，参数为被截断的 section
    var didSelectMoreHandler: ((Int) -> Void)?

    // MARK: - 状态
    private var headerViews: [Int: UIView] = [:]
    private var rowViews: [IndexPath: WSRowView] = [:]
    private var emptyView: WSPluginEmptyPlaceholderView?
    private var layout: Layout?
    private var needsBind = true

    private lazy var moreLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 11.0)
        label.textColor = .secondaryLabel
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.isUserInteractionEnabled = true
        label.isHidden = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(moreLabel)
        moreLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(didTapMore)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 刷新
    /// 数据或配置变化后调用，重新计算布局并绑定数据
    func reloadData() {
        layout = nil
        needsBind = true
        setNeedsLayout()
    }

    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        reloadData()
    }

    /// 没有任何事项时展示空白视图
    var isShowingEmptyView: Bool {
        return contentSections().isEmpty
    }

    /// 全部内容完整展示所需的高度，父视图可据此计算列表高度
    var contentHeight: CGFloat {
        let sections = contentSections()
        guard !sections.isEmpty else {
            return 0.0
        }

        var height = sections.reduce(0.0) { $0 + sectionHeight(forRows: $1.rows) }
        height += CGFloat(sections.count - 1) * max(sectionSpacing, 0.0)
        return height + padding.top + padding.bottom
    }

    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        applyLayoutIfNeeded()
    }

    /// 布局区域未变化且未 reloadData 时直接复用上次的布局结果
    private func applyLayoutIfNeeded() {
        let frame = layoutFrame()
        guard frame.width > 0.0, frame.height > 0.0 else {
            return
        }

        if let layout = layout, layout.frame == frame {
            return
        }

        let newLayout = makeLayout(in: frame)
        layout = newLayout

        let shouldBind = needsBind
        needsBind = false
        apply(newLayout, bind: shouldBind)
    }

    private func contentSections() -> [(section: Int, rows: Int)] {
        var sections: [(section: Int, rows: Int)] = []
        for section in 0..<max(numberOfSections, 0) {
            let rows = max(numberOfRows(in: section), 0)
            guard rows > 0 else {
                continue
            }

            sections.append((section, rows))
        }

        return sections
    }

    private func sectionHeight(forRows rows: Int) -> CGFloat {
        let header = max(sectionHeaderHeight, 0.0)
        let headerSpacing = header > 0.0 ? max(headerRowSpacing, 0.0) : 0.0
        let row = max(rowHeight, 0.0)
        return header + headerSpacing + CGFloat(rows) * row + CGFloat(rows - 1) * max(rowSpacing, 0.0)
    }

    /// 先算出完整高度，超出时为「更多」入口预留位置，再一次遍历生成所有可见视图的坐标
    private func makeLayout(in frame: CGRect) -> Layout {
        var result = Layout(frame: frame)
        let sections = contentSections()
        guard !sections.isEmpty else {
            return result
        }

        let requiredHeight = sections.reduce(0.0) { $0 + sectionHeight(forRows: $1.rows) }
            + CGFloat(sections.count - 1) * max(sectionSpacing, 0.0)
        let showsMore = requiredHeight > frame.height + 0.001
        let moreHeight = min(max(moreEntryHeight, 0.0), frame.height)
        let bottom = frame.maxY - (showsMore ? moreHeight : 0.0)
        let epsilon: CGFloat = 0.001

        var y = frame.minY
        for (index, item) in sections.enumerated() {
            if index > 0 {
                y += max(sectionSpacing, 0.0)
            }

            let header = max(sectionHeaderHeight, 0.0)
            if header > 0.0 {
                guard y + header <= bottom + epsilon else {
                    setMore(&result, section: item.section, hiddenRows: item.rows,
                            frame: frame, moreHeight: moreHeight, top: y)
                    return result
                }

                result.headers.append(HeaderLayout(section: item.section,
                                                   frame: CGRect(x: frame.minX,
                                                                 y: y,
                                                                 width: frame.width,
                                                                 height: header)))
                y += header
            }

            let firstRowSpacing = header > 0.0 ? max(headerRowSpacing, 0.0) : 0.0
            var visibleRows = 0
            while visibleRows < item.rows {
                let top = y + (visibleRows == 0 ? firstRowSpacing : max(rowSpacing, 0.0))
                let row = max(rowHeight, 0.0)
                guard top + row <= bottom + epsilon else {
                    break
                }

                result.rows.append(RowLayout(indexPath: IndexPath(row: visibleRows, section: item.section),
                                             frame: CGRect(x: frame.minX, y: top,
                                                           width: frame.width, height: row)))
                y = top + row
                visibleRows += 1
            }

            if visibleRows < item.rows {
                /// 紧接在最后一行（或首行位置）之后
                let moreSpacing = visibleRows == 0 ? firstRowSpacing : max(rowSpacing, 0.0)
                setMore(&result, section: item.section, hiddenRows: item.rows - visibleRows,
                        frame: frame, moreHeight: moreHeight, top: y + moreSpacing)
                return result
            }
        }

        return result
    }

    private func setMore(_ layout: inout Layout, section: Int, hiddenRows: Int,
                         frame: CGRect, moreHeight: CGFloat, top: CGFloat) {
        let count = moreItemCount(in: section, hiddenRowCount: hiddenRows)
        guard count > 0 else {
            return
        }

        layout.moreSection = section
        layout.moreCount = count
        let leading = min(max(moreLeadingInset, 0.0), frame.width)
        /// 入口紧接在最后一行之后，剩余空间不足时贴底，避免超出布局区域
        let bottom = max(frame.maxY - moreHeight, frame.minY)
        let moreTop = min(max(top, frame.minY), bottom)
        layout.moreFrame = CGRect(x: frame.minX + leading,
                                  y: moreTop,
                                  width: max(frame.width - leading, 0.0),
                                  height: moreHeight)
    }

    // MARK: - 视图
    private func apply(_ layout: Layout, bind: Bool) {
        let showsEmpty = layout.isEmpty
        updateEmptyView(showsEmpty: showsEmpty, frame: layout.frame)

        let visibleSections = Set(layout.headers.map { $0.section })
        for (section, view) in headerViews {
            view.isHidden = showsEmpty || !visibleSections.contains(section)
        }
        for item in layout.headers {
            let (view, isNew) = headerView(at: item.section)
            view.isHidden = false
            view.frame = item.frame
            if bind || isNew {
                updateHeaderView(view, at: item.section)
            }
        }

        let visibleIndexPaths = Set(layout.rows.map { $0.indexPath })
        for (indexPath, view) in rowViews {
            view.isHidden = showsEmpty || !visibleIndexPaths.contains(indexPath)
        }
        for item in layout.rows {
            let (view, isNew) = rowView(at: item.indexPath)
            view.isHidden = false
            view.frame = item.frame
            if bind || isNew {
                updateRowView(view, at: item.indexPath)
            }
        }

        moreLabel.isHidden = layout.moreFrame == nil
        if let moreFrame = layout.moreFrame {
            moreLabel.frame = moreFrame
            moreLabel.text = String(format: resGetString("More %ld"), layout.moreCount)
        }
    }

    private func headerView(at section: Int) -> (UIView, Bool) {
        if let view = headerViews[section] {
            return (view, false)
        }

        let view = makeHeaderView(at: section)
        headerViews[section] = view
        addSubview(view)
        didAddHeaderView(view, at: section)
        return (view, true)
    }

    private func rowView(at indexPath: IndexPath) -> (WSRowView, Bool) {
        if let view = rowViews[indexPath] {
            return (view, false)
        }

        let view = makeRowView(at: indexPath)
        rowViews[indexPath] = view
        addSubview(view)
        didAddRowView(view, at: indexPath)
        return (view, true)
    }

    private func updateEmptyView(showsEmpty: Bool, frame: CGRect) {
        guard showsEmpty else {
            emptyView?.isHidden = true
            return
        }

        if emptyView == nil {
            let view = makeEmptyView()
            emptyView = view
            addSubview(view)
        }

        guard let view = emptyView else {
            return
        }

        view.interactor = interactor
        view.isHidden = false
        view.origin = frame.origin
        view.size = frame.size
        bringSubviewToFront(view)
    }

    // MARK: - 交互
    @objc private func didTapMore() {
        guard let section = layout?.moreSection else {
            return
        }

        didSelectMoreHandler?(section)
    }
}
