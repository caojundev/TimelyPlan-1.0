//
//  CalendarWeekScrollSynchronizer.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/11.
//

import Foundation
import UIKit

class CalendarWeekScrollSynchronizer: NSObject, UIScrollViewDelegate {
    
    /// 全天高度
    var allDayHeight: CGFloat = 0.0 {
        didSet {
            if allDayHeight != oldValue {
                updateAllDayHeight()
            }
        }
    }
    
    private var contentOffset: CGPoint = .zero
    
    internal var eventViews = NSHashTable<CalendarWeekEventsView>.weakObjects()
    
    let hoursView: CalendarWeekTimelineHoursView
    
    /// 动画定时器
    private var displayLink: CADisplayLink?

    /// 参考视图
    private let referenceView = UIView()

    init(hoursView: CalendarWeekTimelineHoursView) {
        self.hoursView = hoursView
        super.init()
        referenceView.isHidden = true
        hoursView.addSubview(referenceView)
        hoursView.contentView.delegate = self
        updateAllDayHeight()
    }
    
    // MARK: - 添加和移除更新器
    func addEventsView(_ eventView: CalendarWeekEventsView) {
        if !eventViews.contains(eventView) {
            eventView.allDayHeight = currentAllDayHeight()
            eventView.contentOffset = contentOffset
            eventViews.add(eventView)
            eventView.scrollViewDelegate = self
        }
    }
    
    private func synchronize() {
        hoursView.contentView.contentOffset = contentOffset
        for eventView in eventViews.allObjects {
            eventView.contentOffset = contentOffset
        }
    }
    
    private func updateAllDayHeight() {
        guard referenceView.height != allDayHeight else {
            return
        }
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .beginFromCurrentState,
                       animations: {
            self.referenceView.height = self.allDayHeight
        }, completion: nil)
        startDisplayLink()
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffset = scrollView.contentOffset
        synchronize()
    }
    
    // MARK: - All-Day Height
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
        hoursView.allDayHeight = currentAllDayHeight
        for eventView in eventViews.allObjects {
            eventView.allDayHeight = currentAllDayHeight
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
