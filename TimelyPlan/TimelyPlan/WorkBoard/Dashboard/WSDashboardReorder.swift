//
//  WSDashboardReorder.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/11.
//

import Foundation
import UIKit

/// 看板拖动排序器。合并长按拖拽、自动滚动与位置交换逻辑，专门用于 WSDashboardView
final class WSDashboardReorder: NSObject, UIGestureRecognizerDelegate {
    
    /// 自动滚动方向
    private enum ScrollDirection {
        case none
        case up
        case down
    }
    
    /// 上下自动滚动感应区域的高度
    private let autoScrollDetectionHeight: CGFloat = 60.0
    
    /// 最快滚动速度
    private let autoScrollMaxVelocity: CGFloat = 15.0
    
    /// 长按后位移超过该距离才进入拖动
    private let draggingBeginDistance: CGFloat = 10.0
    
    /// 拖动快照放大时单边增加的最大长度
    var maxScaleLength: CGFloat = 8.0
    
    /// 排序作用的看板
    private weak var dashboardView: WSDashboardView?
    
    /// 长按手势
    private var longPressGesture: UILongPressGestureRecognizer!
    
    /// 是否拖动中
    private(set) var isMoving: Bool = false
    
    /// 自动滚动驱动
    private var displayLink: CADisplayLink?
    
    /// 自动滚动方向
    private var autoScrollDirection: ScrollDirection = .none
    
    /// 当前触摸点位置
    private(set) var currentPoint = CGPoint.zero
    
    /// 拖动快照视图
    private(set) var draggingView: UIView?
    
    /// 当前拖动索引
    private(set) var draggingIndexPath: IndexPath?
    
    /// 上一次触摸所在索引，用于避免同一位置反复交换
    private var previousIndexPath: IndexPath?
    
    /// 长按识别时的触摸点，用于判断是否达到拖动阈值
    private var initialPoint = CGPoint.zero
    
    private var collectionView: UICollectionView? {
        return dashboardView?.collectionView
    }
    
    /// 是否可用
    var isEnabled: Bool {
        get { return longPressGesture.isEnabled }
        set { longPressGesture.isEnabled = newValue }
    }
    
    init(dashboardView: WSDashboardView) {
        self.dashboardView = dashboardView
        super.init()
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        /// 允许移动范围需大于拖动阈值，否则手势会在进入拖动前被取消
        gesture.allowableMovement = 20.0
        gesture.delegate = self
        dashboardView.collectionView.addGestureRecognizer(gesture)
        self.longPressGesture = gesture
    }
    
    // MARK: - 手势处理
    @objc private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        guard let collectionView = collectionView else {
            return
        }
        
        currentPoint = recognizer.location(in: recognizer.view)
        switch recognizer.state {
        case .began:
            guard let indexPath = collectionView.indexPathForItem(at: currentPoint) else {
                return
            }
            
            /// 长按只记录起点，位移超过阈值后才进入拖动
            draggingIndexPath = indexPath
            previousIndexPath = indexPath
            initialPoint = currentPoint
            isMoving = false
            
            /// 长按已响应即通知看板，此时尚未进入拖动
            dashboardView?.reorderDidRecognizeLongPress(at: indexPath)
            
            /// 立即创建快照并放大，让用户感知长按已响应
            createDraggingView(at: indexPath)
        case .changed:
            guard let indexPath = draggingIndexPath else {
                return
            }
            
            if !isMoving {
                guard distance(from: initialPoint, to: currentPoint) > draggingBeginDistance else {
                    return
                }
                
                /// 交给拖动开始时的平滑移动处理，本次不再直接定位
                beginDragging(at: indexPath)
                return
            }
            
            updateDraggingViewCenter()
            setHidden(true, forItemAt: draggingIndexPath)
            updateAutoScroll()
            if !isAutoScrolling() {
                exchangeIfNeeded()
            }
        default:
            guard let indexPath = draggingIndexPath else {
                return
            }
            
            if isMoving {
                isMoving = false
                
                /// 拖动结束后等待快照归位，再清空拖动状态
                stopAutoScroll()
                resetDraggingView(at: indexPath)
                
                collectionView.isUserInteractionEnabled = true
                dashboardView?.reorderDidEndDragging()
            } else {
                /// 未发生拖动，恢复快照与单元格
                resetDraggingView(at: indexPath)
                
                if recognizer.state == .ended {
                    /// 由看板展示该组件的菜单
                    dashboardView?.reorderDidEndWithoutDragging(at: indexPath)
                }
            }
            
            previousIndexPath = nil
            draggingIndexPath = nil
        }
    }
    
    /// 位移达到阈值，真正进入拖动
    private func beginDragging(at indexPath: IndexPath) {
        /// 快照已在长按响应时创建，这里兜底补建
        if draggingView == nil {
            createDraggingView(at: indexPath)
        }
        
        /// 通知看板预处理，并关闭列表交互避免拖动过程中误触
        dashboardView?.reorderWillBeginDragging(at: indexPath)
        collectionView?.isUserInteractionEnabled = false
        
        isMoving = true
        setHidden(true, forItemAt: indexPath)
        
        /// 进入移动模式，快照平滑移动到手指处并缩放回原尺寸
        updateDraggingViewCenter(animated: true)
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .beginFromCurrentState, animations: {
            self.draggingView?.transform = .identity
        }, completion: nil)
        
        updateAutoScroll()
        exchangeIfNeeded()
    }
    
    /// 创建拖动快照并隐藏原单元格。快照中心与原单元格中心一致，不跟随到手指位置
    private func createDraggingView(at indexPath: IndexPath) {
        guard let collectionView = collectionView,
              let draggingCell = collectionView.cellForItem(at: indexPath),
              let draggingCellSuperView = draggingCell.superview,
              let rootView = UIWindow.keyWindow else {
            return
        }
        
        draggingCell.isHighlighted = false
        let contentViewCornerRadius = draggingCell.contentView.layer.cornerRadius
        let backgroundViewCornerRadius = draggingCell.backgroundView?.layer.cornerRadius ?? 0.0
        let radius = max(contentViewCornerRadius, backgroundViewCornerRadius)
        
        let cellCenter = draggingCellSuperView.convert(draggingCell.center, toViewOrWindow: rootView)
        draggingView = draggingCell.tp_snapshotView(cornerRadius: radius)
        draggingView?.center = cellCenter
        if let draggingView = draggingView {
            rootView.addSubview(draggingView)
        }
        
        /// 隐藏被拖动的单元格
        draggingCell.isHidden = true
        
        /// 长按响应时放大，表示组件已被拿起；进入移动模式后再归位
        let scale = draggingScale(for: draggingCell.bounds.size)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.draggingView?.alpha = 0.9
            self.draggingView?.transform = scale
        }, completion: nil)
    }
    
    /// 快照放大比例。按组件的宽高计算，单边增加的长度不超过 maxScaleLength
    private func draggingScale(for size: CGSize) -> CGAffineTransform {
        guard size.width > 0, size.height > 0 else {
            return .identity
        }
        
        return CGAffineTransform(scaleX: (size.width + maxScaleLength) / size.width,
                                 y: (size.height + maxScaleLength) / size.height)
    }
    
    /// 把拖动视图移动到手指位置
    private func updateDraggingViewCenter(animated: Bool = false) {
        guard let collectionView = collectionView,
              let superview = draggingView?.superview else {
            return
        }
        
        let center = collectionView.convert(currentPoint, toViewOrWindow: superview)
        guard animated else {
            draggingView?.center = center
            return
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState, .curveEaseOut]) {
            self.draggingView?.center = center
        }
    }
    
    private func distance(from start: CGPoint, to end: CGPoint) -> CGFloat {
        return hypot(end.x - start.x, end.y - start.y)
    }
    
    // MARK: - 位置交换
    /// 触摸到新的索引时交换组件位置
    private func exchangeIfNeeded() {
        guard let collectionView = collectionView else {
            return
        }
        
        let touchIndexPath = collectionView.indexPathForItem(at: currentPoint)
        if touchIndexPath == nil || touchIndexPath != previousIndexPath {
            previousIndexPath = nil
        }
        
        guard let fromIndexPath = draggingIndexPath,
              let toIndexPath = touchIndexPath,
              fromIndexPath != toIndexPath,
              toIndexPath != previousIndexPath,
              fromIndexPath.section == toIndexPath.section,
              dashboardView?.reorderMovePlugin(from: fromIndexPath, to: toIndexPath) == true else {
            return
        }
        
        previousIndexPath = fromIndexPath
        /// 拖动索引跟随到新的位置
        changeDraggingIndexPath(toIndexPath)
    }
    
    /// 改变当前拖动索引
    private func changeDraggingIndexPath(_ indexPath: IndexPath?) {
        guard draggingIndexPath != indexPath else {
            return
        }
        
        setHidden(false, forItemAt: draggingIndexPath)
        draggingIndexPath = indexPath
        setHidden(true, forItemAt: indexPath)
    }
    
    // MARK: - 自动滚动
    @objc private func displayDidRefresh() {
        guard let collectionView = collectionView else {
            /// 看板已释放，结束自动滚动，避免定时器继续运行
            stopAutoScroll()
            return
        }
        
        setHidden(true, forItemAt: draggingIndexPath)
        if shouldStopAutoScroll() {
            stopAutoScroll()
            return
        }
        
        /// 触摸点越靠近边缘，滚动速度越快
        let convertedPoint = collectionView.convert(currentPoint, toViewOrWindow: collectionView.superview)
        var dy: CGFloat = 0
        switch autoScrollDirection {
        case .down:
            dy = abs(collectionView.frame.minY + autoScrollDetectionHeight - convertedPoint.y)
        case .up:
            dy = abs(collectionView.frame.maxY - autoScrollDetectionHeight - convertedPoint.y)
        default:
            break
        }
        
        var velocity = (dy / autoScrollDetectionHeight) * autoScrollMaxVelocity
        velocity = min(velocity, autoScrollMaxVelocity)
        
        var height = velocity
        if autoScrollDirection == .down {
            height = -velocity
        }
        
        var offsetY = collectionView.contentOffset.y + height
        offsetY = max(offsetY, -collectionView.adjustedContentInset.top)
        
        collectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
        
        /// 列表滚动后同步触摸点与拖动视图
        currentPoint.y += height
        updateDraggingViewCenter()
    }
    
    /// 是否正在自动滚动
    func isAutoScrolling() -> Bool {
        guard let displayLink = displayLink else {
            return false
        }
        
        return !displayLink.isPaused
    }
    
    private func updateAutoScroll() {
        if shouldStartAutoScroll() {
            startAutoScroll()
        } else {
            stopAutoScroll()
        }
    }
    
    private func shouldStartAutoScroll() -> Bool {
        guard let collectionView = collectionView else {
            return false
        }
        
        let convertedPoint = collectionView.convert(currentPoint, toViewOrWindow: collectionView.superview)
        var shouldStart = false
        if convertedPoint.y < collectionView.frame.minY + autoScrollDetectionHeight {
            autoScrollDirection = .down
            shouldStart = true
        } else if convertedPoint.y > collectionView.frame.maxY - autoScrollDetectionHeight {
            autoScrollDirection = .up
            shouldStart = true
        }
        
        if shouldStopAutoScroll() {
            shouldStart = false
        }
        
        return shouldStart
    }
    
    private func shouldStopAutoScroll() -> Bool {
        if (autoScrollDirection == .down && alreadyScrollToTop()) || (autoScrollDirection == .up && alreadyScrollToBottom()) {
            return true
        }
        
        return false
    }
    
    private func startAutoScroll() {
        stopAutoScroll()
        displayLink = CADisplayLink(target: self, selector: #selector(displayDidRefresh))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    private func stopAutoScroll() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    private func alreadyScrollToTop() -> Bool {
        guard let collectionView = collectionView else {
            return true
        }
        
        let insetTop = max(collectionView.contentInset.top, collectionView.adjustedContentInset.top)
        return collectionView.contentOffset.y <= -insetTop
    }
    
    private func alreadyScrollToBottom() -> Bool {
        guard let collectionView = collectionView else {
            return true
        }
        
        let insetBottom = max(collectionView.contentInset.bottom, collectionView.adjustedContentInset.bottom)
        return collectionView.contentOffset.y + collectionView.bounds.size.height >= collectionView.contentSize.height + insetBottom
    }
    
    // MARK: - 拖动视图
    /// 显示/隐藏索引处的单元格
    private func setHidden(_ isHidden: Bool, forItemAt indexPath: IndexPath?) {
        guard let indexPath = indexPath else {
            return
        }
        
        collectionView?.cellForItem(at: indexPath)?.isHidden = isHidden
    }
    
    /// 拖动视图恢复到原位置
    private func resetDraggingView(at indexPath: IndexPath?) {
        if let indexPath = indexPath,
           let cell = collectionView?.cellForItem(at: indexPath),
           let cellSuperView = cell.superview {
            let center = cellSuperView.convert(cell.center, toViewOrWindow: draggingView?.superview)
            UIView.animate(withDuration: 0.4) {
                self.draggingView?.center = center
                self.draggingView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            } completion: { _ in
                cell.isHidden = false
                self.removeDraggingView()
            }
        } else {
            /// 拖动单元格当前不可见
            UIView.animate(withDuration: 0.4) {
                self.draggingView?.alpha = 0.0
                self.draggingView?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } completion: { _ in
                self.removeDraggingView()
            }
        }
    }
    
    private func removeDraggingView() {
        draggingIndexPath = nil
        collectionView?.visibleCells.forEach { $0.isHidden = false }
        
        draggingView?.removeFromSuperview()
        draggingView = nil
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
