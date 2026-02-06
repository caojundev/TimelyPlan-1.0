//
//  TPCollectionDragReorder.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/29.
//

import Foundation
import UIKit

protocol TPCollectionDragReorderDelegate: AnyObject {
    
    /// 索引处的单元格拖动排序将要开始，做一些预处理操作
    func collectionDragReorder(_ reorder: TPCollectionDragReorder, willBeginAt indexPath: IndexPath)
    
    /// 拖动排序结束
    func collectionDragReorderDidEnd(_ reorder: TPCollectionDragReorder)
    
    /// 默认为false
    func collectionDragReorder(_ reorder: TPCollectionDragReorder, canMoveItemAt indexPath: IndexPath) -> Bool
}

extension TPCollectionDragReorderDelegate {
    
    func collectionDragReorder(_ reorder: TPCollectionDragReorder, willBeginAt indexPath: IndexPath) {
        
    }
    
    func collectionDragReorder(_ reorder: TPCollectionDragReorder, canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionDragReorderDidEnd(_ reorder: TPCollectionDragReorder) {
        
    }
}

class TPCollectionDragReorder: NSObject, UIGestureRecognizerDelegate {
    
    /// 滚动方向
    enum ScrollDirection: UInt {
        case none
        case up
        case down
    }

    /// 代理对象
    weak var delegate: TPCollectionDragReorderDelegate?

    /// 是否可用
    var isEnabled: Bool {
        get { return longPressGesture.isEnabled }
        set { longPressGesture.isEnabled = newValue }
    }

    /// 圆角半径
    var draggingViewCornerRadius: CGFloat = 12.0
    
    /// 上下自动滚动感应区域的高度
    private let autoScrollDetectionHeight: CGFloat = 60.0
    
    /// 最快滚动速度
    private let autoScrollMaxVelocity: CGFloat = 15.0
    
    /// 列表视图
    private(set) var collectionView: UICollectionView
    
    /// 长按手势
    private var longPressGesture: UILongPressGestureRecognizer!
    
    /// 是否移动中
    private(set) var isMoving: Bool = false
    
    /// 自动滚动显示同步
    private var displayLink: CADisplayLink?
    
    ///自动滚动方向
    private var autoScrollDirection = ScrollDirection.none
    
    /// 当前触摸点位置
    private(set) var currentPoint = CGPoint.zero
    
    /// 拖动视图
    private(set) var draggingView: UIView?
    
    /// 当前拖动索引
    private(set) var draggingIndexPath: IndexPath?
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.longPressGesture = UILongPressGestureRecognizer(target: self,
                                                             action: #selector(handleLongPress(_:)))
        self.longPressGesture.allowableMovement = 5.0
        self.longPressGesture.delegate = self
        self.collectionView.addGestureRecognizer(self.longPressGesture)
    }
    
    @objc private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        self.currentPoint = recognizer.location(in: recognizer.view)
        switch recognizer.state {
        case .began:
            /// 判断索引处单元格是否可以移动
            guard let indexPath = collectionView.indexPathForItem(at: self.currentPoint),
                    canMoveItem(at: indexPath) else {
                        return
            }
            
            // 添加拖动视图
            self.draggingIndexPath = indexPath
            /// 通知代理对象
            self.delegate?.collectionDragReorder(self, willBeginAt: indexPath)
            self.collectionView.isUserInteractionEnabled = false
            
            /// 当外部代理更新列表，需要更新currentPoint
            self.currentPoint = recognizer.location(in: recognizer.view)
            self.draggingDidBegin(at: currentPoint)
            
            let draggingCell = collectionView.cellForItem(at: indexPath)
            guard let draggingCell = draggingCell,
                    let draggingCellSuperView = draggingCell.superview,
                    let rootView = UIWindow.keyWindow else {
                        return
            }
            
            draggingCell.isHighlighted = false
            draggingView = draggingCell.tp_snapshotView(cornerRadius: draggingViewCornerRadius)
            draggingView?.center = draggingCellSuperView.convert(draggingCell.center,
                                                                toViewOrWindow: rootView)
            if let draggingView = draggingView {
                rootView.addSubview(draggingView)
            }
            
            /// 隐藏拖动单元格
            draggingCell.isHidden = true
            
            /// 动画移动
            let center = collectionView.convert(currentPoint, toViewOrWindow: draggingView?.superview)
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {
                self.draggingView?.center = center
                self.draggingView?.alpha = 0.9
                self.draggingView?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: nil)

            UIView.animate(withDuration: 0.2, delay: 0.1, options: .beginFromCurrentState, animations: {
                self.draggingView?.transform = .identity
            }, completion: nil)
            
            self.isMoving = true
            self.draggingDidChange(at: self.currentPoint)
        case .changed:
            guard draggingIndexPath != nil else {
                return
            }

            let center = collectionView.convert(currentPoint, toViewOrWindow: draggingView?.superview)
            self.draggingView?.center = center
            
            /// 拖动改变
            self.draggingDidChange(at: currentPoint)
        default:
            self.isMoving = false
            self.draggingDidEnd(at: currentPoint)
            self.draggingIndexPath = nil
            self.collectionView.isUserInteractionEnabled = true
            self.delegate?.collectionDragReorderDidEnd(self)
        }
    }
    
    func draggingDidBegin(at point: CGPoint) {
        // Custom logic
    }
    
    func draggingDidChange(at point: CGPoint) {
        setHidden(true, forItemAt: draggingIndexPath)
        if shouldStartAutoScroll() {
            startAutoScroll()
        } else {
            stopAutoScroll()
        }
    }
    
    func draggingDidEnd(at point: CGPoint) {
        if isAutoScrolling() {
            stopAutoScroll()
        }
    }

    // MARK: - 自动滚动
    @objc func displayDidRefresh() {
        setHidden(true, forItemAt: draggingIndexPath)
        if shouldStopAutoScroll() {
            stopAutoScroll()
            return
        }
        
        /// 计算滚动速度
        let convertedPoint = collectionView.convert(currentPoint, toViewOrWindow: collectionView.superview)
        var dy: CGFloat = 0
        switch autoScrollDirection {
        case .down:
            /// 触摸点在最上方
            dy = abs(collectionView.frame.minY + autoScrollDetectionHeight - convertedPoint.y)
        case .up:
            /// 触摸点在最下方
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
        
        currentPoint.y += height /// 修改当前触摸点y坐标
        draggingView?.center = collectionView.convert(currentPoint, toViewOrWindow: draggingView?.superview)
    }
    
    /// 是否正在自动滚动中
    func isAutoScrolling() -> Bool {
        guard let displayLink = displayLink else {
            return false
        }

        return !displayLink.isPaused
    }
    
    /// 是否开始自动滚动
    private func shouldStartAutoScroll() -> Bool {
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
    
    /// 是否停止自动滚动
    private func shouldStopAutoScroll() -> Bool {
        /// 如果已经滚动到最顶部或最底部
        if (autoScrollDirection == .down && alreadyScrollToTop()) || (autoScrollDirection == .up && alreadyScrollToBottom()) {
            return true
        }
        
        return false
    }
    
    /// 开始自动滚动
    func startAutoScroll() {
        stopAutoScroll()
        displayLink = CADisplayLink(target: self,
                                    selector: #selector(displayDidRefresh))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    /// 结束自动滚动
    func stopAutoScroll() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    /// 是否已经滚动到顶部
    private func alreadyScrollToTop() -> Bool {
        let insetTop = max(collectionView.contentInset.top, collectionView.adjustedContentInset.top)
        return collectionView.contentOffset.y <= -insetTop
    }
    
    /// 是否已经滚动到底部
    private func alreadyScrollToBottom() -> Bool {
        let insetBottom = max(collectionView.contentInset.bottom, collectionView.adjustedContentInset.bottom)
        return collectionView.contentOffset.y + collectionView.bounds.size.height >= collectionView.contentSize.height + insetBottom
    }

    // MARK: - Public Methods
    /// 改变当前拖动索引
    func changeDraggingIndexPath(_ indexPath: IndexPath?) {
        guard self.draggingIndexPath != indexPath else {
            return
        }
        
        if let draggingIndexPath = draggingIndexPath {
            setHidden(false, forItemAt: draggingIndexPath)
        }
        
        self.draggingIndexPath = indexPath
        setHidden(true, forItemAt: indexPath)
        
        if self.draggingIndexPath == nil {
            stopReordering()
        }
    }
    
    /// 显示/隐藏索引处的单元格
    func setHidden(_ isHidden: Bool, forItemAt indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.isHidden = isHidden
        }
    }
    
    /// 拖动视图恢复到原位
    func resetDraggingView(at indexPath: IndexPath?) {
        if let indexPath = indexPath,
           let cell = collectionView.cellForItem(at: indexPath),
           let cellSuperView = cell.superview {
            let center = cellSuperView.convert(cell.center, toViewOrWindow: self.draggingView?.superview)
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
    
    func removeDraggingView() {
        self.draggingIndexPath = nil
        /// 显示可见Cell
        for cell in collectionView.visibleCells {
            cell.isHidden = false
        }
        
        self.draggingView?.removeFromSuperview()
        self.draggingView = nil
    }
    
    func stopReordering() {
        if !isMoving {
            return
        }
        
        removeDraggingView()
        longPressGesture.isEnabled = false
        longPressGesture.isEnabled = true
    }
    
    private func canMoveItem(at indexPath: IndexPath) -> Bool {
        return delegate?.collectionDragReorder(self, canMoveItemAt: indexPath) ?? true
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
