//
//  CalendarDragDropManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/16.
//

import Foundation

protocol CalendarDragDropManagerDelegate: AnyObject {
    
    // 创建新事项
    func calendarDragDropManager(_ manager: CalendarDragDropManager, createEventWithDateRange dateRange: DateInterval)
    
    /// 更新事项日期
    func calendarDragDropManager(_ manager: CalendarDragDropManager,
                                 updateEvent event: CalendarEvent,
                                 withDateRange dateRange: DateInterval,
                                 completion: @escaping((Bool) -> Void))
}

class CalendarDragDropManager: CalendarDragDropManageViewDelegate {

    weak var delegate: CalendarDragDropManagerDelegate?
    
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
    
    func showEvent(_ event: CalendarEvent) {
        let manageView = CalendarDragDropManageView(event: event)
        manageView.delegate = self
        showManangeView(manageView)
    }
    
    func showAddEvent(with dateRange: DateInterval) {
        let manageView = CalendarDragDropManageView(dateRange: dateRange)
        manageView.delegate = self
        showManangeView(manageView)
    }
    
    func dismiss() {
        pageView?.synchronizer.removeSynchronizableView(manageView)
        manageView?.dismiss()
        manageView = nil
        /// 清除高亮
        pageView?.clearHighlight()
    }
    
    private func showManangeView(_ manageView: CalendarDragDropManageView) {
        if self.manageView != nil {
            dismiss()
        }
        
        guard let pageView = pageView else {
            return
        }
        
        manageView.pageView = pageView
        self.manageView = manageView
        updateManageViewFrame()
        pageView.addSubview(manageView)
        
        /// 将管理视图添加到同步器
        pageView.synchronizer.addSynchronizableView(manageView)
    }
    
    private func updateManageViewFrame() {
        guard let eventsFrame = eventsFrame,
              let manageView = manageView else {
            return
        }
        
        manageView.frame = eventsFrame
    }
    
    // MARK: -
    
    func dragDropManageView(_ view: CalendarDragDropManageView, didEndEditingDateRange dateRange: DateInterval) {
        guard let event = view.event else {
            /// 创建新事项
            delegate?.calendarDragDropManager(self, createEventWithDateRange: dateRange)
            dismiss()
            return
        }
        
        guard let delegate = delegate, event.dateRange != dateRange else {
            dismiss()
            return
        }

        delegate.calendarDragDropManager(self,
                                         updateEvent: event,
                                         withDateRange: dateRange) { [weak self] _ in
            self?.dismiss()
        }
    }
    
    
}
