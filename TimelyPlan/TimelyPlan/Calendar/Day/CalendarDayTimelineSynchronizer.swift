//
//  CalendarDayTimelineSynchronizer.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/8.
//

import Foundation
import UIKit

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
    private var timelineViews = NSHashTable<CalendarDayTimelineView>.weakObjects()
    
    /// 动画定时器
    private var displayLink: CADisplayLink?

    /// 参考视图
    private let referenceView = UIView()

    init(view: UIView) {
        super.init()
        referenceView.isHidden = true
        view.addSubview(referenceView)
    }
    
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
    private func updateAllDayHeight() {
//        print("更新高度：\(allDayHeight)")
//        for timelineView in timelineViews.allObjects {
//            timelineView.allDayHeight = currentAllDayHeight()
//        }

        guard referenceView.height != allDayHeight else {
            return
        }

        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .beginFromCurrentState,
                       animations: {
            self.referenceView.height = self.allDayHeight
        })
        
        startDisplayLink()
    }

    private func startDisplayLink() {
        if displayLink != nil {
            return;
        }
     
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkAction))
        displayLink?.add(to: RunLoop.current, forMode: .common)
    }

    private func stopDisplayLink() {
        if displayLink != nil {
            displayLink!.invalidate()
            displayLink = nil
        }
    }
    
    @objc private func displayLinkAction() {
        let currentAllDayHeight = currentAllDayHeight()
        for timelineView in timelineViews.allObjects {
            timelineView.allDayHeight = currentAllDayHeight
        }
        
        if currentAllDayHeight == allDayHeight {
            stopDisplayLink()
        }
    }
    
    private func currentAllDayHeight() -> CGFloat {
        if let presentation = referenceView.layer.presentation() {
            return presentation.frame.height
        }

        return allDayHeight
    }
    
}
