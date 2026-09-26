//
//  GoalTimelineViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/26.
//

import Foundation
import UIKit

/// 目标计划时间线视图控制器
///
/// 用于展示当前目标计划下所有目标任务的时间线。
class GoalTimelineViewController: GanttTimelineListViewController {
    
    /// 时间线视图模型
    private var viewModel: GoalTimelineViewModel
    
    /// 事项点击处理器
    private let eventProcessor = GanttEventProcessor()
    
    // MARK: - Initialization
    init(configuration: GoalListConfiguration) {
        self.viewModel = GoalTimelineViewModel(configuration: configuration)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 左侧关闭按钮
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        setupViewModel()
        setRowHeightType(.medium)
        reloadEvents()
    }
    
    override var themeBackgroundColor: UIColor? {
        return GanttTimelineConfig.eventListBackgroundColor
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return GanttTimelineConfig.eventListBackgroundColor
    }
    
    // MARK: - GanttTimelineListViewController
    /// 加载当前目标计划下的目标任务
    override func reloadEvents() {
        viewModel.loadEvents()
    }
    
    override func clickEvent(_ event: GanttEvent) {
        eventProcessor.clickEvent(event)
    }
    
    // MARK: - 数据加载
    /// 绑定视图模型回调
    private func setupViewModel() {
        viewModel.onEventsChanged = { [weak self] in
            guard let self = self else {
                return
            }
            
            self.timelineView.events = self.viewModel.events ?? []
        }
    }
}
