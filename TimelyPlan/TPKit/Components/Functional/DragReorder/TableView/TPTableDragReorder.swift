//
//  TPTableDragReorder.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/24.
//

import Foundation
import UIKit

protocol TPTableDragReorderDataSource: AnyObject {
    /// 动态获取特定索引对应的代理对象
    func tableDragReorder(_ reorder: TPTableDragReorder, delegateForRowAt indexPath: IndexPath) -> TPTableDragReorderDelegate?
}

protocol TPTableDragReorderDelegate: AnyObject {
    
    /// 索引处的单元格拖动排序将要开始，做一些预处理操作
    func tableDragReorder(_ reorder: TPTableDragReorder, willBeginAt indexPath: IndexPath)
    
    /// 拖动排序结束
    func tableDragReorderDidEnd(_ reorder: TPTableDragReorder)
    
    /// 默认为false
    func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool
}

extension TPTableDragReorderDataSource {
    func tableDragReorder(_ reorder: TPTableDragReorder, delegateForRowAt indexPath: IndexPath) -> TPTableDragReorderDelegate? { return nil }
}

extension TPTableDragReorderDelegate {
    
    func tableDragReorderDidEnd(_ reorder: TPTableDragReorder) { }
}

class TPTableDragReorder: NSObject, UIGestureRecognizerDelegate {
    
    /// 滚动方向
    enum ScrollDirection: UInt {
        case none
        case up
        case down
    }

    /// 数据源
    weak var dataSource: TPTableDragReorderDataSource?
    
    /// 代理对象
    weak var delegate: TPTableDragReorderDelegate?

    /// 是否可用
    var isEnabled: Bool {
        get { return longPressGesture.isEnabled }
        set { longPressGesture.isEnabled = newValue }
    }

    /// 上下自动滚动感应区域的高度
    private let autoScrollDetectionHeight: CGFloat = 60.0
    
    /// 最快滚动速度
    private let autoScrollMaxVelocity: CGFloat = 15.0
    
    /// 圆角半径
    private let draggingViewCornerRadius: CGFloat = 12.0
    
    /// 列表视图
    private(set) var tableView: UITableView
    
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
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.longPressGesture = UILongPressGestureRecognizer(target: self,
                                                             action: #selector(handleLongPress(_:)))
        self.longPressGesture.allowableMovement = 5.0
        self.longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(self.longPressGesture)
    }
    
    @objc private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        self.currentPoint = recognizer.location(in: recognizer.view)
        switch recognizer.state {
        case .began:
            guard let indexPath = tableView.indexPathForRow(at: self.currentPoint) else {
                return
            }
            
            if let dataSource = dataSource {
                /// 通过数据源获取代理对象
                delegate = dataSource.tableDragReorder(self, delegateForRowAt: indexPath)
            }
            
            /// 判断索引处单元格是否可以移动
            guard canMoveRow(at: indexPath) else {
                return
            }
            
            // 添加拖动视图
            self.draggingIndexPath = indexPath
            self.delegate?.tableDragReorder(self, willBeginAt: indexPath)
            self.tableView.isUserInteractionEnabled = false
            
            /// 当外部代理更新列表，需要更新currentPoint
            self.currentPoint = recognizer.location(in: recognizer.view)
            self.draggingDidBegin(at: currentPoint)
            
            let draggingCell = tableView.cellForRow(at: indexPath)
            guard let draggingCell = draggingCell,
                    let draggingCellSuperView = draggingCell.superview,
                    let rootView = UIWindow.keyWindow else {
                        return
            }
            
            draggingCell.setHighlighted(false, animated: false)
            draggingView = draggingCell.tp_snapshotView(cornerRadius: draggingViewCornerRadius)
            draggingView?.center = draggingCellSuperView.convert(draggingCell.center,
                                                                toViewOrWindow: rootView)
            if let draggingView = draggingView {
                rootView.addSubview(draggingView)
            }
            
            /// 隐藏拖动单元格
            draggingCell.isHidden = true
            
            /// 动画移动
            let center = tableView.convert(currentPoint, toViewOrWindow: draggingView?.superview)
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

            let center = tableView.convert(currentPoint, toViewOrWindow: draggingView?.superview)
            self.draggingView?.center = center
            
            /// 拖动改变
            self.draggingDidChange(at: currentPoint)
        default:
            self.isMoving = false
            self.draggingDidEnd(at: currentPoint)
            self.draggingIndexPath = nil
            self.tableView.isUserInteractionEnabled = true
            self.delegate?.tableDragReorderDidEnd(self)
        }
    }
    
    func draggingDidBegin(at point: CGPoint) {
        // Custom logic
    }
    
    func draggingDidChange(at point: CGPoint) {
        setHidden(true, forRowAt: draggingIndexPath)
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
    @objc private func displayDidRefresh() {
        setHidden(true, forRowAt: draggingIndexPath)
        if shouldStopAutoScroll() {
            stopAutoScroll()
            return
        }
        
        /// 计算滚动速度
        let convertedPoint = tableView.convert(currentPoint, toViewOrWindow: tableView.superview)
        var dy: CGFloat = 0
        switch autoScrollDirection {
        case .down:
            /// 触摸点在最上方
            dy = abs(tableView.frame.minY + autoScrollDetectionHeight - convertedPoint.y)
        case .up:
            /// 触摸点在最下方
            dy = abs(tableView.frame.maxY - autoScrollDetectionHeight - convertedPoint.y)
        default:
            break
        }
        
        var velocity = (dy / autoScrollDetectionHeight) * autoScrollMaxVelocity
        velocity = min(velocity, autoScrollMaxVelocity)
        
        var height = velocity
        if autoScrollDirection == .down {
            height = -velocity
        }
        
        var offsetY = tableView.contentOffset.y + height
        offsetY = max(offsetY, -tableView.adjustedContentInset.top)
        
        tableView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
        
        currentPoint.y += height /// 修改当前触摸点y坐标
        draggingView?.center = tableView.convert(currentPoint, toViewOrWindow: draggingView?.superview)
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
        let convertedPoint = tableView.convert(currentPoint, toViewOrWindow: tableView.superview)
        var shouldStart = false
        if convertedPoint.y < tableView.frame.minY + autoScrollDetectionHeight {
            autoScrollDirection = .down
            shouldStart = true
        } else if convertedPoint.y > tableView.frame.maxY - autoScrollDetectionHeight {
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
        let insetTop = max(tableView.contentInset.top, tableView.adjustedContentInset.top)
        return tableView.contentOffset.y <= -insetTop
    }
    
    /// 是否已经滚动到底部
    private func alreadyScrollToBottom() -> Bool {
        let insetBottom = max(tableView.contentInset.bottom, tableView.adjustedContentInset.bottom)
        return tableView.contentOffset.y + tableView.bounds.size.height >= tableView.contentSize.height + insetBottom
    }

    // MARK: - Public Methods
    /// 改变当前拖动索引
    func changeDraggingIndexPath(_ indexPath: IndexPath?) {
        guard self.draggingIndexPath != indexPath else {
            return
        }
        
        if let draggingIndexPath = draggingIndexPath {
            setHidden(false, forRowAt: draggingIndexPath)
        }
        
        self.draggingIndexPath = indexPath
        setHidden(true, forRowAt: indexPath)
        
        if self.draggingIndexPath == nil {
            stopReordering()
        }
    }
    
    /// 显示/隐藏索引处的单元格
    func setHidden(_ isHidden: Bool, forRowAt indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.isHidden = isHidden
        }
    }
    
    
    func removeDraggingView() {
        self.draggingIndexPath = nil
        /// 显示可见Cell
        for cell in tableView.visibleCells {
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
    
    private func canMoveRow(at indexPath: IndexPath) -> Bool {
        return delegate?.tableDragReorder(self, canMoveRowAt: indexPath) ?? false
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
