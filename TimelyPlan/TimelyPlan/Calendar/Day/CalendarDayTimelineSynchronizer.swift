//
//  CalendarDayTimelineSynchronizer.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/8.
//

import Foundation

class CalendarDayTimelineSynchronizer: NSObject, UIScrollViewDelegate {
    
    /// 全天高度
    var allDayHeight: CGFloat = 0.0 {
        didSet {
            if allDayHeight != oldValue {
                updateAllDayHeight()
            }
        }
    }
    
    /// 当前内容偏移
    private var contentOffset: CGPoint = .zero
    
    /// 时间线视图
    internal var timelineViews = NSHashTable<CalendarDayTimelineView>.weakObjects()
    
    private func synchronize() {
        for timelineView in timelineViews.allObjects {
            timelineView.contentOffset = contentOffset
        }
    }
    
    func setContentOffset(_ contentOffset: CGPoint) {
        self.contentOffset = contentOffset
        synchronize()
    }
    
    // MARK: - 添加和移除更新器
    func addTimelineView(_ timelineView: CalendarDayTimelineView) {
        timelineView.allDayHeight = currentAllDayHeight()
        timelineView.contentOffset = contentOffset
        if !timelineViews.contains(timelineView) {
            timelineViews.add(timelineView)
            timelineView.scrollViewDelegate = self
        }
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffset = scrollView.contentOffset
        synchronize()
    }
    
    // MARK: -
    func currentAllDayHeight() -> CGFloat {
        return allDayHeight
    }
    
    private func updateAllDayHeight() {
        for timelineView in timelineViews.allObjects {
            timelineView.allDayHeight = currentAllDayHeight()
        }
        
//        guard referenceView.height != allDayHeight else {
//            return
//        }
//        
//        UIView.animate(withDuration: 0.25,
//                       delay: 0.0,
//                       options: .beginFromCurrentState,
//                       animations: {
//            self.referenceView.height = self.allDayHeight
//        }, completion: nil)
//        startDisplayLink()
    }
    
}
