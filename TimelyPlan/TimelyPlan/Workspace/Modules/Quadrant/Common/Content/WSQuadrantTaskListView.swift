//
//  WSQuadrantTaskListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation
import UIKit

// MARK: - 象限卡片

/// 四象限任务列表视图（单个象限卡片）。
///
/// 顶部为象限头视图，下方为未完成任务列表与更多入口，各尺寸组件共用。
/// 行数与更多入口由 `WSMoreRowListView` 统一管理：行数按可用高度换算，
/// 任务超出可展示行数时最后一行让给更多入口；象限内没有任务时展示「无任务」占位。
class WSQuadrantTaskListView: WSMoreRowListView, QuadrantTitleViewDelegate {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 卡片圆角
        static let cornerRadius: CGFloat = 16.0
        
        /// 头视图高度
        static let headerHeight: CGFloat = 36.0
        
        /// 列表与卡片边缘的间距
        static let contentInset = UIEdgeInsets(value: 4.0)
        
        /// 卡片底色
        static let backgroundColor = Color(light: 0x232323, 0.04, dark: 0xFFFFFF, 0.04)
        
        /// 更多入口字体
        static let moreFont = UIFont.boldSystemFont(ofSize: 11.0)
    }
    
    /// 所属象限。单象限组件在数据到达后更新
    private(set) var quadrant: Quadrant {
        didSet {
            guard quadrant != oldValue else {
                return
            }
            
            titleView.quadrant = quadrant
            updateMoreButtonColor()
            updateRowContents()
            /// 空白占位的图标跟随象限变化
            reloadEmptyView()
            setNeedsLayout()
        }
    }
    
    /// 点击头视图回调
    var didSelectHeaderHandler: ((Quadrant) -> Void)?
    
    /// 点击添加按钮回调
    var didClickAddHandler: ((Quadrant) -> Void)?
    
    /// 点击更多入口回调
    var didSelectMoreEntryHandler: ((Quadrant) -> Void)?
    
    /// 点击任务回调
    var didSelectTaskHandler: ((WSTodoTaskItem) -> Void)?
    
    /// 点击完成状态回调
    var didClickCheckboxHandler: ((WSTodoTaskItem) -> Void)?
    
    /// 当前展示的象限数据
    private(set) var quadrantGroup: WSQuadrantTaskGroup?
    
    /// 任务行的最小高度。可用高度更大时行数会相应增加
    private let minimumRowHeight: CGFloat
    
    /// 头视图
    private lazy var titleView: QuadrantTitleView = {
        let view = QuadrantTitleView(quadrant: quadrant, position: .bottom)
        view.removeSeparator() /// 删除分割线
        view.delegate = self
        return view
    }()
    
    init(quadrant: Quadrant, minimumRowHeight: CGFloat = 30.0, rowSpacing: CGFloat = 0.0) {
        self.quadrant = quadrant
        self.minimumRowHeight = max(minimumRowHeight, 1.0)
        super.init(frame: .zero)
        
        self.backgroundColor = Metrics.backgroundColor
        self.layer.cornerRadius = Metrics.cornerRadius
        self.clipsToBounds = true
        
        /// 任务行单列排布，内边距为卡片与列表的间距，行间距由外部传入
        self.columnCount = 1
        self.rowSpacing = max(rowSpacing, 0.0)
        self.padding = Metrics.contentInset
        
        addSubview(titleView)
        setupMoreButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 更多入口配置
    /// 更多入口沿用原来的纯文字样式：无底色、象限色文案，标题在整行内居中
    private func setupMoreButton() {
        moreButton.cornerRadius = 0.0
        moreButton.padding = .zero
        moreButton.titleConfig.font = Metrics.moreFont
        moreButton.normalBackgroundColor = .clear
        moreButton.selectedBackgroundColor = .clear
        moreButton.preferredTappedScale = 1.0
        moreButton.didClickHandler = { [weak self] in
            guard let self = self else {
                return
            }
            
            self.didSelectMoreEntryHandler?(self.quadrant)
        }
        
        updateMoreButtonColor()
    }
    
    /// 更多入口文案颜色跟随象限
    private func updateMoreButtonColor() {
        moreButton.titleConfig.textColor = quadrant.color
        moreButton.titleConfig.highlightedTextColor = quadrant.color
        moreButton.titleConfig.selectedTextColor = quadrant.color
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        /// 行数随可用高度变化，先更新行数并绑定任务，再交给基类补齐行视图与更多入口
        updateRowCountIfNeeded()
        updateRowContents()
        super.layoutSubviews()
        
        titleView.frame = CGRect(x: 0.0,
                                 y: 0.0,
                                 width: bounds.width,
                                 height: min(Metrics.headerHeight, bounds.height))
    }
    
    /// 行区域位于头视图下方
    override var rowsLayoutFrame: CGRect {
        var frame = super.rowsLayoutFrame
        let headerOffset = min(Metrics.headerHeight, bounds.height)
        frame.origin.y += headerOffset
        frame.size.height = max(frame.height - headerOffset, 0.0)
        return frame
    }
    
    /// 行数按可用高度换算，行高在各象限之间保持一致；没有任务时不展示行
    private func updateRowCountIfNeeded() {
        guard let tasks = quadrantGroup?.tasks, !tasks.isEmpty else {
            if rowCount != 0 {
                rowCount = 0
            }
            return
        }
        
        let listHeight = rowsLayoutFrame.height
        guard listHeight > 0.0 else {
            return
        }
        
        let slotCount = max(Int((listHeight + rowSpacing) / (minimumRowHeight + rowSpacing)), 1)
        guard rowCount != slotCount else {
            return
        }
        
        rowCount = slotCount
    }
    
    // MARK: - 更多入口
    /// 与原来的更多入口一致：文案为「还有 N 项」，按钮占满整行、标题居中
    override func layoutMoreEntry() {
        super.layoutMoreEntry()
        
        /// 基类按行列数统一显示行视图，任务不足的位置需要重新隐藏
        let taskCount = min(quadrantGroup?.tasks.count ?? 0, numberOfItems)
        for (index, rowView) in rowViews.enumerated() where index >= taskCount {
            rowView.isHidden = true
        }
        
        guard !moreButton.isHidden, numberOfItems > 0 else {
            return
        }
        
        /// 更多入口紧跟最后一个任务，任务不足时不再留出空行
        let moreIndex = min(taskCount, numberOfItems - 1)
        moreButton.title = String(format: resGetString("And %ld More"), overflowCount)
        moreButton.frame = itemLayoutFrame(at: moreIndex)
    }
    
    // MARK: - 空白视图
    /// 象限内没有任务时展示「无任务」占位
    override func makeEmptyView() -> WSPluginEmptyPlaceholderView {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = quadrant.smallPlaceholderImageName
        configuration.title = resGetString("No Task")
        return WSPluginIconTitleEmptyPlaceholderView(configuration: configuration)
    }
    
    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return WSTodoTaskRowView()
    }
    
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        super.didAddRowView(rowView, at: index)
        
        guard let rowView = rowView as? WSTodoTaskRowView else {
            return
        }
        
        rowView.didSelectTaskHandler = { [weak self] dataItem in
            self?.didSelectTaskHandler?(dataItem)
        }
        rowView.didClickCheckboxHandler = { [weak self] dataItem in
            self?.didClickCheckboxHandler?(dataItem)
        }
        
        /// 新建的行立即绑定当前任务，避免出现空白行
        let task = quadrantGroup?.tasks[safe: index]
        rowView.update(with: task, color: quadrant.color)
        rowView.isHidden = task == nil
    }
    
    // MARK: - 渲染
    /// 更新象限任务。传 nil 时清空内容
    func update(withQuadrant group: WSQuadrantTaskGroup?) {
        self.quadrantGroup = group
        if let group = group {
            self.quadrant = group.quadrant
        }
        
        totalItemCount = group?.totalCount ?? 0
        updateRowCountIfNeeded()
        updateRowContents()
        reloadData()
        setNeedsLayout()
    }
    
    /// 按顺序把任务绑定到行视图，任务不足的行不展示
    private func updateRowContents() {
        let tasks = quadrantGroup?.tasks ?? []
        for (index, rowView) in rowViews.enumerated() {
            let task = tasks[safe: index]
            (rowView as? WSTodoTaskRowView)?.update(with: task, color: quadrant.color)
            rowView.isHidden = task == nil
        }
    }
    
    // MARK: - QuadrantTitleViewDelegate
    func quadrantTitleViewDidClickAdd(_ titleView: QuadrantTitleView) {
        didClickAddHandler?(quadrant)
    }
    
    func quadrantTitleViewDidTap(_ titleView: QuadrantTitleView) {
        didSelectHeaderHandler?(quadrant)
    }
}
