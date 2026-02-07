//
//  FocusTimelineSynchronizer.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/7.
//

import Foundation

class FocusTimelineSynchronizer: NSObject, UIScrollViewDelegate {
    
    /// 当前内容偏移
    private var contentOffset: CGPoint = .zero
    
    /// 时间线视图
    internal var timelineViews = NSHashTable<FocusTimelineView>.weakObjects()
    
    // MARK: - 添加和移除更新器
    func addTimelineView(_ timelineView: FocusTimelineView) {
        if !timelineViews.contains(timelineView) {
            timelineView.contentOffset = contentOffset
            timelineViews.add(timelineView)
            timelineView.scrollViewDelegate = self
        }
    }
    
    private func synchronize() {
        for timelineView in timelineViews.allObjects {
            timelineView.contentOffset = contentOffset
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffset = scrollView.contentOffset
        synchronize()
    }
    
}
