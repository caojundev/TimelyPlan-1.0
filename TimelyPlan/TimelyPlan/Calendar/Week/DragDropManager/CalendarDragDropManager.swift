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
    private(set) weak var pageView: CalendarWeekPageView?
    
    /// 拖放容器视图
    private var manageView: CalendarDragDropManageView?
    
    init(pageView: CalendarWeekPageView) {
        self.pageView = pageView
    }
    
    func show() {
        manageView?.removeFromSuperview()
        manageView = nil
        
        guard let pageView = pageView else {
            return
        }

        let manageView = CalendarDragDropManageView(pageView: pageView)
        self.manageView = manageView
        updateManageViewFrame()
        pageView.addSubview(manageView)
    }
    
    func dismiss() {
        manageView?.removeFromSuperview()
        manageView = nil
    }
    
    private func updateManageViewFrame() {
        guard let eventsFrame = eventsFrame else {
            return
        }
        
        manageView?.frame = eventsFrame
    }
}
