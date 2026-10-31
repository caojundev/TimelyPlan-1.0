//
//  WSQuadrantTasksContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 四象限·大·任务的内容视图。
///
/// 以两列两行的网格展示四个象限，每个象限为一张卡片：头视图可进入象限详情、可快速添加任务，
/// 卡片内为未完成任务列表，任务超出 4 条时展示更多入口。
class WSQuadrantTasksContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 8.0)
        
        /// 象限之间的间距
        static let spacing: CGFloat = 6.0
    }
    
    /// 象限卡片
    private lazy var quadrantViews: [Quadrant: WSQuadrantTaskListView] = {
        var views = [Quadrant: WSQuadrantTaskListView]()
        for quadrant in Quadrant.allCases {
            views[quadrant] = WSQuadrantTaskListView(quadrant: quadrant)
        }
        
        return views
    }()
    
    /// 象限的展示顺序
    private var order: [Quadrant] = Quadrant.allCases
    
    /// 任务快速添加管理器，首次添加时创建
    private var quickAddManager: TodoTaskQuickAddManager?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        
        for quadrant in Quadrant.allCases {
            guard let quadrantView = quadrantViews[quadrant] else {
                continue
            }
            
            quadrantView.didSelectHeaderHandler = { [weak self] quadrant in
                self?.showDetail(for: quadrant)
            }
            quadrantView.didClickAddHandler = { [weak self] quadrant in
                self?.showQuickAdd(for: quadrant)
            }
            quadrantView.didSelectMoreHandler = { [weak self] quadrant in
                self?.showDetail(for: quadrant)
            }
            quadrantView.didSelectTaskHandler = { [weak self] dataItem in
                self?.interactor?.performAction(with: dataItem)
            }
            quadrantView.didClickCheckboxHandler = { [weak self] dataItem in
                (self?.interactor as? WSQuadrantTasksContentInteractor)?.clickCheckbox(for: dataItem)
            }
            
            addSubview(quadrantView)
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
        
        let itemWidth = max((contentFrame.width - Metrics.spacing) / 2.0, 0.0)
        let itemHeight = max((contentFrame.height - Metrics.spacing) / 2.0, 0.0)
        
        for (index, quadrant) in order.enumerated() {
            guard let quadrantView = quadrantViews[quadrant] else {
                continue
            }
            
            let row = CGFloat(index / 2)
            let column = CGFloat(index % 2)
            quadrantView.frame = CGRect(x: contentFrame.minX + column * (itemWidth + Metrics.spacing),
                                        y: contentFrame.minY + row * (itemHeight + Metrics.spacing),
                                        width: itemWidth,
                                        height: itemHeight)
        }
    }
    
    // MARK: - 交互
    /// 进入象限详情，与四象限主页面点击象限标题的行为一致
    private func showDetail(for quadrant: Quadrant) {
        WSQuadrantDetailPresenter.showDetail(for: quadrant, from: self)
    }
    
    /// 快速添加任务，与四象限主页面点击添加按钮的行为一致
    private func showQuickAdd(for quadrant: Quadrant) {
        guard let viewController = parentViewController else {
            return
        }
        
        if quickAddManager == nil {
            quickAddManager = TodoTaskQuickAddManager(containerViewController: viewController)
        }
        
        let filterRule = QuadrantSetting.shared.filterRule(for: quadrant)
        quickAddManager?.show(with: filterRule.matchingQuickAddTask)
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem as? WSQuadrantTasksDataItem else {
            for quadrantView in quadrantViews.values {
                quadrantView.update(with: nil)
            }
            
            setNeedsLayout()
            return
        }
        
        order = dataItem.quadrants.map { $0.quadrant }
        for item in dataItem.quadrants {
            quadrantViews[item.quadrant]?.update(with: item)
        }
        
        setNeedsLayout()
    }
}
