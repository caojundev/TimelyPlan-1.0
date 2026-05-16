//
//  CalendarWeekScrollSynchronizer.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/11.
//

import Foundation
import UIKit

protocol CalendarScrollSynchronizable {
    
    /// 全天高度
    var allDayHeight: CGFloat {get set}
    
    /// 滚动代理对象
    var scrollViewDelegate: UIScrollViewDelegate? { get set}
    
    /// 内容偏移
    var contentOffset: CGPoint { get set}
}

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
    
    internal var synchronizableViews = NSHashTable<UIView>.weakObjects()
    
    /// 动画定时器
    private var displayLink: CADisplayLink?

    /// 参考视图
    private let referenceView = UIView()
    
    init(hoursView: CalendarWeekTimelineHoursView) {
        super.init()
        referenceView.isHidden = true
        hoursView.addSubview(referenceView)
        addSynchronizableView(hoursView)
        updateAllDayHeight()
    }
    
    // MARK: - 添加和移除更新器
    func addSynchronizableView(_ view: CalendarScrollSynchronizable) {
        guard let aView = view as? UIView else {
            return
        }
        
        if !synchronizableViews.contains(aView) {
            aView.layoutIfNeeded()
            
            var synchronizableView = view
            synchronizableView.allDayHeight = currentAllDayHeight()
            synchronizableView.contentOffset = contentOffset
            synchronizableView.scrollViewDelegate = self
            synchronizableViews.add(aView)
        }
    }
    
    private func synchronize() {
        for view in synchronizableViews.allObjects {
            if var synchronizableView = view as? CalendarScrollSynchronizable {
                synchronizableView.contentOffset = contentOffset
            }
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
        self.contentOffset = scrollView.contentOffset
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
        for view in synchronizableViews.allObjects {
            if var synchronizableView = view as? CalendarScrollSynchronizable {
                synchronizableView.allDayHeight = currentAllDayHeight
            }
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
