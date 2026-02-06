//
//  TodoTaskBoardDragInsertReorder.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/24.
//

import Foundation

struct PageIndexPath: Equatable {
    var page: Int
    var section: Int
    var row: Int
    
    /// 任务索引
    var taskIndexPath: IndexPath {
        return IndexPath(item: row, section: section)
    }
    
    // MARK: - Equatable
    static func == (lhs: PageIndexPath, rhs: PageIndexPath) -> Bool {
        return lhs.page == rhs.page && lhs.section == rhs.section && lhs.row == rhs.row
    }
}

protocol TodoTaskBoardDragInsertReorderDelegate: AnyObject {

    /// 默认为 false
    func todoTaskBoardDragInsertReorder(_ reorder: TodoTaskBoardDragInsertReorder, canMoveItemAt indexPath: PageIndexPath) -> Bool

    /// 索引处的单元格拖动排序将要开始，做一些预处理操作
    func todoTaskBoardDragInsertReorder(_ reorder: TodoTaskBoardDragInsertReorder, willBeginAt indexPath: PageIndexPath)
    
    /// 拖动排序结束
    func todoTaskBoardDragInsertReorderDidEnd(_ reorder: TodoTaskBoardDragInsertReorder)
    
    /// 是否可以将源索引处条目插入到目标索引处
    func todoTaskBoardDragInsertReorder(_ reorder: TodoTaskBoardDragInsertReorder,
                                        canInsertItemTo targetIndexPath: PageIndexPath,
                                        from sourceIndexPath: PageIndexPath) -> Bool

    /// 执行将源索引处条目插入到目标索引处
    func todoTaskBoardDragInsertReorder(_ reorder: TodoTaskBoardDragInsertReorder,
                                        inserItemTo targetIndexPath: PageIndexPath,
                                        from sourceIndexPath: PageIndexPath)
}

class TodoTaskBoardDragInsertReorder: NSObject,
                                      UIGestureRecognizerDelegate,
                                        TPAutoScrollerDelegate {
    
    /// 插入位置
    enum InsertPosition {
        case atStart
        case atEnd
    }
    
    /// 代理对象
    weak var delegate: TodoTaskBoardDragInsertReorderDelegate?

    /// 是否可用
    var isEnabled: Bool {
        get { return longPressGesture.isEnabled }
        set { longPressGesture.isEnabled = newValue }
    }

    /// 圆角半径
    private let draggingViewCornerRadius: CGFloat = 12.0
    
    /// 是否移动中
    private(set) var isMoving: Bool = false

    /// 当前触摸点位置
    private(set) var currentPoint = CGPoint.zero
    
    /// 当前触摸页面视图
    private(set) var currentPageView: TodoTaskPageView?
    
    /// 拖动视图
    private(set) var draggingView: UIView?
    
    /// 当前拖动索引
    private var draggingIndexPath: PageIndexPath?
    
    /// 目标索引信息
    private var targetIndexPath: PageIndexPath?
    
    /// 长按手势
    private var longPressGesture: UILongPressGestureRecognizer!

    /// 看板水平自动滚动器
    private let boardAutoScroller = TPHorizontalAutoScroller()
    
    /// 页面垂直自动滚动器
    private let pageAutoScroller = TPVerticalAutoScroller()
    
    /// 看板视图
    private(set) var boardView: TodoTaskBoardView
    
    /// 空白页插入区域高度
    private let blankPageInsertAreaHeight = 180.0
    
    init(boardView: TodoTaskBoardView) {
        self.boardView = boardView
        super.init()
        self.boardAutoScroller.delegate = self
        self.boardAutoScroller.scrollView = boardView.scrollView
        self.pageAutoScroller.delegate = self
        self.longPressGesture = UILongPressGestureRecognizer(target: self,
                                                             action: #selector(handleLongPress(_:)))
        self.longPressGesture.allowableMovement = 5.0
        self.longPressGesture.delegate = self
        self.boardView.addGestureRecognizer(self.longPressGesture)
    }
    
    @objc private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        self.currentPoint = recognizer.location(in: recognizer.view)
        switch recognizer.state {
        case .began:
            /// 判断索引处单元格是否可以移动
            guard let indexPath = boardView.touchIndexPath(at: currentPoint),
                    canMoveItem(at: indexPath),
                    let draggingCell = boardView.cellForItem(at: indexPath),
                    let draggingCellSuperView = draggingCell.superview,
                    let rootView = UIWindow.keyWindow else {
                return
            }
            
            draggingIndexPath = indexPath
            delegate?.todoTaskBoardDragInsertReorder(self, willBeginAt: indexPath)
            boardView.isUserInteractionEnabled = false
            draggingDidBegin(at: currentPoint)
            draggingCell.isHighlighted = false
            draggingView = draggingCell.tp_snapshotView(cornerRadius: draggingViewCornerRadius)
            draggingView?.center = draggingCellSuperView.convert(draggingCell.center, toViewOrWindow: rootView)
            if let draggingView = draggingView, let rootView = UIWindow.keyWindow {
                rootView.addSubview(draggingView)
            }
            
            /// 隐藏拖动单元格
            draggingCell.isHidden = true
            let draggingCenter = boardView.convert(currentPoint, toViewOrWindow: draggingView?.superview)
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .beginFromCurrentState, animations: {
                self.draggingView?.center = draggingCenter
                self.draggingView?.alpha = 0.9
                self.draggingView?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: nil)

            UIView.animate(withDuration: 0.2, delay: 0.1, options: .beginFromCurrentState, animations: {
                self.draggingView?.transform = .identity
            }, completion: nil)
            
            isMoving = true
            draggingDidChange(at: currentPoint)
        case .changed:
            guard draggingIndexPath != nil else {
                return
            }
            
            draggingView?.center = boardView.convert(currentPoint, toViewOrWindow: draggingView?.superview)
            draggingDidChange(at: currentPoint)
        default:
            isMoving = false
            draggingDidEnd(at: currentPoint)
            boardView.isUserInteractionEnabled = true
            delegate?.todoTaskBoardDragInsertReorderDidEnd(self)
        }
    }
    
    func draggingDidBegin(at point: CGPoint) {
        clearTargetAndHideIndicator()
        update(with: point)
    }
    
    func draggingDidChange(at point: CGPoint) {
        hideCell(at: draggingIndexPath)
        
        let touchInfo = (point, boardView)
        boardAutoScroller.updateTouchInfo(touchInfo)
        updateCurrentPageView(at: point)
        pageAutoScroller.scrollView = currentPageView?.scrollView
        pageAutoScroller.updateTouchInfo(touchInfo)
        update(with: point)
    }
    
    func draggingDidEnd(at point: CGPoint) {
        boardAutoScroller.stopAutoScroll()
        pageAutoScroller.scrollView = nil
        pageAutoScroller.stopAutoScroll()
        update(with: point)
        
        if let draggingIndexPath = draggingIndexPath, let targetIndexPath = targetIndexPath {
            print("插入到 \(targetIndexPath)")
            delegate?.todoTaskBoardDragInsertReorder(self, inserItemTo: targetIndexPath, from: draggingIndexPath)
        }
        
        if targetIndexPath == nil {
            resetDraggingView(at: draggingIndexPath)
        } else {
            resetDraggingView(at: nil)
        }
        
        clearTargetAndHideIndicator()
    }
    
    // MARK: - Update
    func updateCurrentPageView(at point: CGPoint) {
        let pageView = boardView.pageView(at: point)
        if currentPageView != pageView {
            currentPageView?.hideInsertIndicator()
            currentPageView = pageView
        }
    }
    
    /// 更新指示视图和插入位置信息
    private func update(with touchPoint: CGPoint) {
        guard let draggingIndexPath = draggingIndexPath else {
            clearTargetAndHideIndicator()
            return
        }
        
        guard let pageView = currentPageView, let page = pageView.indexPath?.item else {
            return
        }
        
        /// 目标索引
        var targetIndexPath: PageIndexPath?
        let pagePoint = boardView.convert(touchPoint, toViewOrWindow: pageView)
        if let taskIndexPath = pageView.insertIndexPathForItem(at: pagePoint),
            let cell = pageView.cellForItem(at: taskIndexPath) {
            let convertedTouchPoint = boardView.convert(touchPoint, toViewOrWindow: cell.superview)
            var insertPosition: InsertPosition = .atStart
            if convertedTouchPoint.y >= cell.frame.midY {
                insertPosition = .atEnd
            }
            
            let insertIndexPath = PageIndexPath(page: page,
                                                section: taskIndexPath.section,
                                                row: taskIndexPath.item)
            targetIndexPath = destinationIndexPath(fromIndexPath: draggingIndexPath,
                                                   touchIndexPath: insertIndexPath,
                                                   insertPosition: insertPosition)
            if let indexPath = targetIndexPath, !canInsertItem(to: indexPath) {
                targetIndexPath = nil
            }
            
            if targetIndexPath != nil {
                pageView.showInsertIndicator(at: taskIndexPath, atEnd: insertPosition == .atEnd)
            } else {
                pageView.hideInsertIndicator()
            }
        } else {
            if page != draggingIndexPath.page, !pageView.hasTask, pagePoint.y < blankPageInsertAreaHeight {
                /// 当前为空白页，触摸点在插入区域内
                targetIndexPath = PageIndexPath(page: page, section: 0, row: 0)
            }
            
            if let indexPath = targetIndexPath, !canInsertItem(to: indexPath) {
                targetIndexPath = nil
            }
            
            if targetIndexPath != nil {
                pageView.showInsertIndicatorAtTop()
            } else {
                pageView.hideInsertIndicator()
            }
        }

        /// 判断是否可以插入到目标索引处
        self.targetIndexPath = targetIndexPath
    }

    /// 清除目标索引并隐藏插入指示器
    private func clearTargetAndHideIndicator() {
        targetIndexPath = nil
        currentPageView?.hideInsertIndicator()
    }
    
    func resetDraggingIndexPath() {
        showCell(at: draggingIndexPath)
        draggingIndexPath = nil
    }
    
    /// 显示/隐藏索引处的单元格
    func removeDraggingView() {
        draggingView?.removeFromSuperview()
        draggingView = nil
    }
    
    func resetDraggingView(at indexPath: PageIndexPath?) {
        if let indexPath = indexPath, let cell = boardView.cellForItem(at: indexPath) {
            let center = cell.convert(cell.bounds.middlePoint, toViewOrWindow: draggingView?.superview)
            UIView.animate(withDuration: 0.4) {
                self.draggingView?.center = center
                self.draggingView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            } completion: { _ in
                cell.isHidden = false
                self.resetDraggingIndexPath()
                self.removeDraggingView()
            }
        } else {
            resetDraggingIndexPath()
            UIView.animate(withDuration: 0.4) {
                self.draggingView?.alpha = 0.0
                self.draggingView?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } completion: { _ in
                self.removeDraggingView()
            }
        }
    }
    
    /// 结束排序
    func stopReordering() {
        if !isMoving {
            return
        }
        
        removeDraggingView()
        longPressGesture.isEnabled = false
        longPressGesture.isEnabled = true
    }
    
    // MARK: - 显示 / 隐藏单元格
    func showCell(at indexPath: PageIndexPath?) {
        setHidden(false, forCellAt: indexPath)
    }
    
    func hideCell(at indexPath: PageIndexPath?) {
        setHidden(true, forCellAt: indexPath)
    }
     
    func setHidden(_ isHidden: Bool, forCellAt indexPath: PageIndexPath?) {
        guard let indexPath = indexPath else {
            return
        }

        if let cell = boardView.cellForItem(at: indexPath) {
            cell.isHidden = isHidden
        }
    }
    
    // MARK: - TPAutoScrollerDelegate
    func autoScrollerDidRefresh(_ scroller: TPAutoScroller) {
        /// 隐藏当前拖动单元格
        hideCell(at: draggingIndexPath)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Helpers
    /// 获取目标索引
    private func destinationIndexPath(fromIndexPath: PageIndexPath,
                                      touchIndexPath: PageIndexPath?,
                                      insertPosition: InsertPosition) -> PageIndexPath {
        guard let touchIndexPath = touchIndexPath else {
            return fromIndexPath
        }

        var targetIndexPath = touchIndexPath
        guard fromIndexPath.page == touchIndexPath.page else {
            /// 在不同页面移动
            if insertPosition == .atEnd {
                targetIndexPath.row = touchIndexPath.row + 1
            }
            
            return targetIndexPath
        }
        
        /// 相同页面内移动
        if insertPosition == .atStart {
            if fromIndexPath.section == touchIndexPath.section && fromIndexPath.row < touchIndexPath.row {
                targetIndexPath.row = touchIndexPath.row - 1
            }
        } else {
            if fromIndexPath.section != touchIndexPath.section ||
                fromIndexPath.row > touchIndexPath.row {
                targetIndexPath.row = touchIndexPath.row + 1
            }
        }
        
        return targetIndexPath
    }
    
    // MARK: - Delegate Helpers
    private func canMoveItem(at indexPath: PageIndexPath) -> Bool {
        return true
        return delegate?.todoTaskBoardDragInsertReorder(self, canMoveItemAt: indexPath) ?? false
    }
    
    private func canInsertItem(to indexPath: PageIndexPath) -> Bool {
        return true
        if draggingIndexPath == indexPath {
            return true
        }
        
        if let sourceIndexPath = draggingIndexPath, let delegate = delegate {
            return delegate.todoTaskBoardDragInsertReorder(self,
                                                           canInsertItemTo: indexPath,
                                                           from: sourceIndexPath)
        }

        return false
    }
}
