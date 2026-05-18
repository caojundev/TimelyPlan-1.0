//
//  CalendarDragDropManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/16.
//

import Foundation

class CalendarDragDropManager {
    
    /// 事项显示区域
    var eventsFrame: CGRect? {
        didSet {
            updateManageViewFrame()
        }
    }
    
    var isActive: Bool {
        return manageView != nil
    }
    
    /// 页面视图
    private(set) weak var pageView: CalendarPageView?
    
    /// 拖放容器视图
    private var manageView: CalendarDragDropManageView?
    
    init(pageView: CalendarPageView) {
        self.pageView = pageView
    }
    
    func showAddEvent(with dateRange: CalendarTimelineDateRange) {
        manageView?.removeFromSuperview()
        manageView = nil
        
        guard let pageView = pageView else {
            return
        }
        
        let manageView = CalendarDragDropManageView(dateRange: dateRange)
        manageView.pageView = pageView
        self.manageView = manageView
        updateManageViewFrame()
        pageView.addSubview(manageView)
        
        /// 将管理视图添加到同步器
        pageView.synchronizer.addSynchronizableView(manageView)
    }
    
    func dismiss() {
        pageView?.clearHighlight()
        manageView?.removeFromSuperview()
        manageView = nil
    }
    
    private func updateManageViewFrame() {
        guard let eventsFrame = eventsFrame,
              let manageView = manageView else {
            return
        }
        
        manageView.frame = eventsFrame
    }
}
