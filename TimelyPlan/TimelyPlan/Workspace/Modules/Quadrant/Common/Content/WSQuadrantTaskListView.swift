//
//  WSQuadrantTaskListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation
import UIKit

// MARK: - 象限卡片

/// 四象限任务列表视图（单个象限卡片）。顶部为象限头视图，下方为未完成任务列表与更多入口，各尺寸组件共用。
class WSQuadrantTaskListView: UIView, QuadrantTitleViewDelegate {
    
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
            moreButton.setTitleColor(quadrant.color, for: .normal)
            setNeedsLayout()
        }
    }
    
    /// 点击头视图回调
    var didSelectHeaderHandler: ((Quadrant) -> Void)?
    
    /// 点击添加按钮回调
    var didClickAddHandler: ((Quadrant) -> Void)?
    
    /// 点击更多入口回调
    var didSelectMoreHandler: ((Quadrant) -> Void)?
    
    /// 点击任务回调
    var didSelectTaskHandler: ((WSTodoTaskItem) -> Void)?
    
    /// 点击完成状态回调
    var didClickCheckboxHandler: ((WSTodoTaskItem) -> Void)?
    
    /// 当前展示的象限数据
    private(set) var dataItem: WSQuadrantTaskGroup?
    
    /// 任务行的最小高度。可用高度更大时行数会相应增加
    private let minimumRowHeight: CGFloat
    
    /// 任务行之间的间距
    private let rowSpacing: CGFloat
    
    /// 头视图
    private lazy var titleView: QuadrantTitleView = {
        let view = QuadrantTitleView(quadrant: quadrant, position: .bottom)
        view.removeSeparator() /// 删除分割线
        view.delegate = self
        return view
    }()
    
    /// 任务行视图，按可用高度动态创建
    private var taskRowViews: [WSTodoTaskRowView] = []
    
    /// 更多入口
    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = Metrics.moreFont
        button.setTitleColor(self.quadrant.color, for: .normal)
        button.addTarget(self, action: #selector(clickMore(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    init(quadrant: Quadrant, minimumRowHeight: CGFloat = 30.0, rowSpacing: CGFloat = 0.0) {
        self.quadrant = quadrant
        self.minimumRowHeight = max(minimumRowHeight, 1.0)
        self.rowSpacing = max(rowSpacing, 0.0)
        super.init(frame: .zero)
        
        self.backgroundColor = Metrics.backgroundColor
        self.layer.cornerRadius = Metrics.cornerRadius
        self.clipsToBounds = true
        
        addSubview(titleView)
        addSubview(moreButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds.width > 0.0, bounds.height > 0.0 else {
            return
        }
        
        let headerHeight = min(Metrics.headerHeight, bounds.height)
        titleView.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: headerHeight)
        
        /// 行数按列表可用高度换算，行高在各象限之间保持一致；更多入口占用任务行之后的槽位
        let listTop = headerHeight + Metrics.contentInset.top
        let listHeight = max(bounds.height - headerHeight - Metrics.contentInset.verticalLength, 0.0)
        let slotCount = max(Int((listHeight + rowSpacing) / (minimumRowHeight + rowSpacing)), 1)
        let rowHeight = max((listHeight - CGFloat(slotCount - 1) * rowSpacing) / CGFloat(slotCount), 0.0)
        let rowStep = rowHeight + rowSpacing
        let (taskCount, hiddenCount) = displayedTaskCounts(slotCount: slotCount)
        
        for index in 0..<slotCount {
            let rowView = rowView(at: index)
            let task = index < taskCount ? dataItem?.tasks[safe: index] : nil
            
            rowView.update(with: task, color: quadrant.color)
            rowView.isHidden = task == nil
            rowView.frame = CGRect(x: Metrics.contentInset.left,
                                   y: listTop + CGFloat(index) * rowStep,
                                   width: max(bounds.width - Metrics.contentInset.horizontalLength, 0.0),
                                   height: rowHeight)
        }
        
        for index in slotCount..<taskRowViews.count {
            taskRowViews[index].isHidden = true
        }
        
        moreButton.frame = CGRect(x: 0.0,
                                  y: listTop + CGFloat(taskCount) * rowStep,
                                  width: bounds.width,
                                  height: rowHeight)
        updateMoreButton(hiddenCount: hiddenCount)
    }
    
    /// 按需创建任务行视图
    private func rowView(at index: Int) -> WSTodoTaskRowView {
        while taskRowViews.count <= index {
            let rowView = WSTodoTaskRowView()
            rowView.didSelectTaskHandler = { [weak self] dataItem in
                self?.didSelectTaskHandler?(dataItem)
            }
            rowView.didClickCheckboxHandler = { [weak self] dataItem in
                self?.didClickCheckboxHandler?(dataItem)
            }
            
            taskRowViews.append(rowView)
            insertSubview(rowView, belowSubview: moreButton)
        }
        
        return taskRowViews[index]
    }
    
    /// 需要展示的任务数与未展示的任务数。任务超出可用行数时，最后一行留给更多入口
    private func displayedTaskCounts(slotCount: Int) -> (taskCount: Int, hiddenCount: Int) {
        let tasks = dataItem?.tasks ?? []
        let totalCount = dataItem?.totalCount ?? 0
        
        var taskCount = min(tasks.count, slotCount)
        if totalCount > taskCount, slotCount > 1 {
            /// 行数不足时只留一行给更多入口
            taskCount = min(tasks.count, slotCount - 1)
        }
        
        return (taskCount, max(totalCount - taskCount, 0))
    }
    
    /// 更新更多入口的文案与显隐
    private func updateMoreButton(hiddenCount: Int) {
        moreButton.isHidden = hiddenCount <= 0
        guard hiddenCount > 0 else {
            return
        }
        
        let title = String(format: resGetString("And %ld More"), hiddenCount)
        moreButton.setTitle(title, for: .normal)
    }
    
    // MARK: - 渲染
    /// 更新象限任务。传 nil 时清空内容
    func update(with dataItem: WSQuadrantTaskGroup?) {
        self.dataItem = dataItem
        if let dataItem = dataItem {
            self.quadrant = dataItem.quadrant
        }
        
        setNeedsLayout()
    }
    
    // MARK: - 交互
    @objc private func clickMore(_ sender: UIButton) {
        didSelectMoreHandler?(quadrant)
    }
    
    // MARK: - QuadrantTitleViewDelegate
    func quadrantTitleViewDidClickAdd(_ titleView: QuadrantTitleView) {
        didClickAddHandler?(quadrant)
    }
    
    func quadrantTitleViewDidTap(_ titleView: QuadrantTitleView) {
        didSelectHeaderHandler?(quadrant)
    }
}
