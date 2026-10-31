//
//  WSQuadrantLargeQuadrantView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation
import UIKit

// MARK: - 象限卡片

/// 四象限·大·任务的象限卡片。顶部为象限头视图，下方为未完成任务列表与更多入口。
class WSQuadrantLargeQuadrantView: UIView, QuadrantTitleViewDelegate {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 卡片圆角
        static let cornerRadius: CGFloat = 8.0
        
        /// 头视图高度
        static let headerHeight: CGFloat = 32.0
        
        /// 列表与卡片边缘的间距
        static let contentInset = UIEdgeInsets(value: 4.0)
        
        /// 最多展示的任务数
        static let maximumTaskCount = WSQuadrantLargeContentInteractor.maximumTaskCount
        
        /// 卡片底色
        static let backgroundColor = Color(light: 0x000000, 0.04, dark: 0xFFFFFF, 0.08)
        
        /// 更多入口字体
        static let moreFont = UIFont.boldSystemFont(ofSize: 11.0)
    }
    
    /// 所属象限
    let quadrant: Quadrant
    
    /// 点击头视图回调
    var didSelectHeaderHandler: ((Quadrant) -> Void)?
    
    /// 点击添加按钮回调
    var didClickAddHandler: ((Quadrant) -> Void)?
    
    /// 点击更多入口回调
    var didSelectMoreHandler: ((Quadrant) -> Void)?
    
    /// 当前展示的象限数据
    private(set) var dataItem: WSQuadrantLargeQuadrantItem?
    
    /// 头视图
    private lazy var titleView: QuadrantTitleView = {
        let view = QuadrantTitleView(quadrant: quadrant, position: .bottom)
        view.removeSeparator() /// 删除分割线
        view.delegate = self
        return view
    }()
    
    /// 任务行视图
    private lazy var taskRowViews: [WSQuadrantLargeTaskRowView] = {
        return (0..<Metrics.maximumTaskCount).map { _ in WSQuadrantLargeTaskRowView() }
    }()
    
    /// 更多入口
    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = Metrics.moreFont
        button.setTitleColor(self.quadrant.color, for: .normal)
        button.addTarget(self, action: #selector(clickMore(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    init(quadrant: Quadrant) {
        self.quadrant = quadrant
        super.init(frame: .zero)
        
        self.backgroundColor = Metrics.backgroundColor
        self.layer.cornerRadius = Metrics.cornerRadius
        self.clipsToBounds = true
        
        addSubview(titleView)
        taskRowViews.forEach { addSubview($0) }
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
        
        /// 固定上限个槽位，行高在各象限之间保持一致；更多入口占用任务行之后的槽位，不压缩任务行
        let listTop = headerHeight + Metrics.contentInset.top
        let listHeight = max(bounds.height - headerHeight - Metrics.contentInset.verticalLength, 0.0)
        let rowHeight = listHeight / CGFloat(Metrics.maximumTaskCount)
        let taskCount = min(dataItem?.tasks.count ?? 0, Metrics.maximumTaskCount)
        
        for (index, rowView) in taskRowViews.enumerated() {
            guard index < taskCount else {
                continue
            }
            
            rowView.frame = CGRect(x: Metrics.contentInset.left,
                                   y: listTop + CGFloat(index) * rowHeight,
                                   width: max(bounds.width - Metrics.contentInset.horizontalLength, 0.0),
                                   height: rowHeight)
        }
        
        moreButton.frame = CGRect(x: 0.0,
                                  y: listTop + CGFloat(taskCount) * rowHeight,
                                  width: bounds.width,
                                  height: rowHeight)
    }
    
    // MARK: - 渲染
    /// 更新象限任务。传 nil 时清空内容
    func update(with dataItem: WSQuadrantLargeQuadrantItem?) {
        self.dataItem = dataItem
        
        let tasks = dataItem?.tasks ?? []
        let taskCount = min(tasks.count, Metrics.maximumTaskCount)
        for (index, rowView) in taskRowViews.enumerated() {
            let task = index < taskCount ? tasks[safe: index] : nil
            rowView.update(with: task, color: quadrant.color)
            rowView.isHidden = task == nil
        }
        
        let hiddenCount = dataItem?.hiddenCount ?? 0
        moreButton.isHidden = hiddenCount <= 0
        if hiddenCount > 0 {
            let title = String(format: resGetString("And %ld More"), hiddenCount)
            moreButton.setTitle(title, for: .normal)
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
