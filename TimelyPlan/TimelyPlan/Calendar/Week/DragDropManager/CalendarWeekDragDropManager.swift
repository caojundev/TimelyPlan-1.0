//
//  CalendarDragDropManager.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/20.
//

import Foundation

class CalendarWeekDragDropManager: NSObject,
                                    UIGestureRecognizerDelegate,
                                    TPAutoScrollerDelegate {

    /// 代理对象
    weak var delegate: AnyObject?

    /// 是否可用
    var isEnabled: Bool {
        get {
            return longPressGesture.isEnabled
        }
        
        set {
            longPressGesture.isEnabled = newValue
        }
    }

    /// 列表视图
    private(set) var pageView: CalendarWeekPageView
    
    /// 长按手势
    private var longPressGesture: UILongPressGestureRecognizer!
    
    /// 是否移动中
    private(set) var isMoving: Bool = false

    /// 当前触摸点位置
    private(set) var currentPoint = CGPoint.zero
    
    /// 拖动视图
    private(set) var draggingView: UIView?

    private var timelineAutoScroller = TPVerticalAutoScroller()
    
    init(pageView: CalendarWeekPageView) {
        self.pageView = pageView
        super.init()
        self.longPressGesture = UILongPressGestureRecognizer(target: self,
                                                             action: #selector(handleLongPress(_:)))
        self.longPressGesture.allowableMovement = 5.0
        self.longPressGesture.delegate = self
        self.pageView.addGestureRecognizer(longPressGesture)
        
        self.timelineAutoScroller.scrollView = pageView.timelineScrollView
        self.timelineAutoScroller.autoScrollDetectionLength = 120.0
        self.timelineAutoScroller.delegate = self
        
    }
    
    @objc private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        self.currentPoint = recognizer.location(in: pageView)
        switch recognizer.state {
        case .began:
            guard let eventView = pageView.eventView(at: currentPoint) else {
                return
            }
            
            self.pageView.isUserInteractionEnabled = false
            self.draggingDidBegin(at: currentPoint)
            draggingView = eventView.tp_snapshotView(cornerRadius: 2.0)
            
            /// 设置锚点
            let eventViewOrigin = eventView.convert(CGPoint.zero, toViewOrWindow: pageView)
            
            draggingView?.layer.anchorPoint = CGPoint(x: (currentPoint.x - eventViewOrigin.x) / eventView.width,
                                                      y: (currentPoint.y - eventViewOrigin.y) / eventView.height)
            draggingView?.center = currentPoint
            if let draggingView = draggingView {
                pageView.addSubview(draggingView)
            }

//            eventView.alpha = 0.4
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {
                self.draggingView?.center = self.currentPoint
                self.draggingView?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: nil)
            UIView.animate(withDuration: 0.2, delay: 0.1, options: .beginFromCurrentState, animations: {
                self.draggingView?.transform = .identity
            }, completion: nil)
            isMoving = true
            draggingDidChange(at: currentPoint)
        case .changed:
            guard draggingView != nil else {
                return
            }

            draggingView?.center = currentPoint
            draggingDidChange(at: currentPoint)
        default:
            isMoving = false
            draggingDidEnd(at: currentPoint)
            pageView.isUserInteractionEnabled = true
        }
    }
    
    func draggingDidBegin(at point: CGPoint) {
        highlightDateRange()
    }
    
    func draggingDidChange(at point: CGPoint) {
        highlightDateRange()
        timelineAutoScroller.updateTouchInfo((point, pageView))
        
//        setHidden(true, forItemAt: draggingIndexPath)
//
//        let quadrantView = matrixView.quadrantView(at: point)
//        guard let quadrantView = quadrantView,
//              quadrantView.quadrant != draggingIndexPath?.quadrant,
//              canMoveItem(to: quadrantView.quadrant) else {
//            resetTargetQuadrantView()
//            return
//        }
//
//        if targetQuadrantView != quadrantView {
//            TPImpactFeedback.impactWithSoftStyle()
//            targetQuadrantView?.isHighlighted = false
//            targetQuadrantView = quadrantView
//            targetQuadrantView?.isHighlighted = true
//        }
    }
    
    func draggingDidEnd(at point: CGPoint) {
        draggingView?.removeFromSuperview()
        draggingView = nil
        clearHighlight()
//        let sourceIndexPath = draggingIndexPath
//        if let indexPath = draggingIndexPath {
//            setHidden(false, forItemAt: indexPath)
//        }
//
//        var targetQuadrant: Quadrant?
//        if let targetQuadrantView = targetQuadrantView {
//            targetQuadrant = targetQuadrantView.quadrant
//            resetTargetQuadrantView()
//        }
//
//        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut) {
//            self.draggingView?.alpha = 0.0
//            self.draggingView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//        } completion: { _ in
//            self.draggingIndexPath = nil
//            self.draggingView?.removeFromSuperview()
//            self.draggingView = nil
//        }
//
//        if let sourceIndexPath = sourceIndexPath, let targetQuadrant = targetQuadrant {
//            delegate?.quadrantDragDropController(self, moveItemAt: sourceIndexPath, to: targetQuadrant)
//        }
    }
    
    private func highlightDateRange() {
        guard let draggingView = draggingView else {
            return
        }

        let start = pageView.timeOffset(at: draggingView.origin)
        let end = start + SECONDS_PER_HOUR
        let range = CalendarTimelineRange(start: start, end: end)
        pageView.highlightRange(range)
    }
    
    private func clearHighlight() {
        pageView.clearHighlight()
    }
    
    // MARK: -
    
    func stopDragging() {
        if !isMoving {
            return
        }

//        if let draggingIndexPath = draggingIndexPath {
//            setHidden(false, forItemAt: draggingIndexPath)
//        }
//
//        draggingIndexPath = nil
        draggingView?.removeFromSuperview()
        draggingView = nil
        longPressGesture.isEnabled = false
        longPressGesture.isEnabled = true
    }
    
    /// 显示/隐藏索引处的单元格
//    func setHidden(_ isHidden: Bool, forItemAt indexPath: QuadrantIndexPath?) {
//        guard let indexPath = indexPath else {
//            return
//        }
//
//        if let cell = matrixView.cellForItem(at: indexPath) {
//            cell.isHidden = isHidden
//        }
//    }
//
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    /*
    // MARK: - Helpers
    
    private func canMoveItem(at indexPath: QuadrantIndexPath) -> Bool {
        return delegate?.quadrantDragDropController(self, canMoveItemAt: indexPath) ?? false
    }
    
    private func canMoveItem(to quadrant: Quadrant) -> Bool {
        return delegate?.quadrantDragDropController(self, canMoveItemTo: quadrant) ?? false
    }
    */
    
    // MARK: - TPAutoScrollerDelegate
    func autoScrollerDidRefresh(_ scroller: TPAutoScroller) {
        
    }
}
