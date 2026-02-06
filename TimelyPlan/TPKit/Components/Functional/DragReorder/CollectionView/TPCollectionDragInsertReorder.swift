//
//  TPCollectionDragInsertReorder.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/29.
//

import Foundation
import UIKit

protocol TPCollectionDragInsertReorderDelegate: TPCollectionDragReorderDelegate {
    
    /// 获取插入到目标索引处的缩进
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                indentationLevelTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                ratio: CGFloat) -> Int
    
    /// 获取当前聚焦索引
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                focusIndexPathTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                depth: Int) -> IndexPath?

    /// 是否可以闪烁行
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                canFlashItemAt indexPath: IndexPath,
                                from sourceIndexPath: IndexPath) -> Bool
    
    /// 闪烁行
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                didFlashItemAt indexPath: IndexPath,
                                from sourceIndexPath: IndexPath)
    
    /// 是否可以将源索引处条目插入到目标索引处
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                canInsertItemTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath) -> Bool

    /// 执行将源索引处条目插入到目标索引处
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                inserItemTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                depth: Int) -> IndexPath?
}

extension TPCollectionDragInsertReorderDelegate {
    
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                indentationLevelTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                ratio: CGFloat) -> Int {
        return 0
    }
    
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                focusIndexPathTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                depth: Int) -> IndexPath? {
        return nil
    }

    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                canFlashItemAt indexPath: IndexPath,
                                from sourceIndexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder, didFlashItemAt indexPath: IndexPath, from sourceIndexPath: IndexPath) {
       
    }
    
    /// 是否可以将源索引处条目插入到目标索引处
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                     canInsertItemTo targetIndexPath: IndexPath,
                                     from sourceIndexPath: IndexPath) -> Bool {
        return false
    }

}

class TPCollectionDragInsertReorder: TPCollectionDragReorder {
    
    /// 插入位置
    enum InsertPosition {
        case before
        case after
    }

    /// 指示视图颜色
    var indicatorLineColor: UIColor = Color(0x046BDE) {
        didSet {
            insertIndicatorView.lineColor = indicatorLineColor
        }
    }
    
    /// 插入指示器背景色
    var indicatorBackColor: UIColor = Color(0xFFFFFF, 0.8) {
        didSet {
            insertIndicatorView.backColor = indicatorBackColor
        }
    }

    /// 缩进宽度
    var indentationWidth: CGFloat = 20.0 {
        didSet {
            insertIndicatorView.indentationWidth = indentationWidth
        }
    }
    
    /// 指示视图高度
    let indicatorHeight = 4.0

    /// 插入指示视图
    private lazy var insertIndicatorView: TPDragInsertIndicatorView = {
        let view = TPDragInsertIndicatorView()
        view.lineColor = indicatorLineColor
        return view
    }()
    
    /// 聚焦指示视图
    private lazy var focusIndicatorView: TPDragFocusIndicatorView = {
        let view = TPDragFocusIndicatorView()
        view.alpha = 0.8
        return view
    }()
    
    /// 拖动插入时间管理器
    private lazy var monitor: TPDragInsertFlashMonitor = {
        let monitor = TPDragInsertFlashMonitor()
        monitor.completion = { [weak self] indexPath in
            self?.commitFlashing(at: indexPath)
        }
        
        return monitor
    }()

    /// 目标索引
    private var target: (indexPath: IndexPath, depth: Int)?
    
    override func startAutoScroll() {
        super.startAutoScroll()
        self.unhighlight()
    }
    
    // MARK: - 拖动生命周期
    override func draggingDidBegin(at point: CGPoint) {
        super.draggingDidBegin(at: point)
        self.clearTargetAndHideIndicator()
        self.focusIndicatorView.isHidden = true
        self.collectionView.addSubview(self.focusIndicatorView)
        self.insertIndicatorView.isHidden = true
        self.collectionView.addSubview(self.insertIndicatorView)
        self.update(with: point)
    }
    
    override func draggingDidChange(at point: CGPoint) {
        super.draggingDidChange(at: point)
        if isAutoScrolling() {
            /// 滚动中结束管理器时钟监测
            monitor.stop()
        } else {
            update(with: point)
        }
    }

    override func draggingDidEnd(at point: CGPoint) {
        super.draggingDidEnd(at: point)
        self.update(with: point)
        self.monitor.reset()
         
        let resetAction = {
            self.resetDraggingView(at: self.draggingIndexPath)
            self.clearTargetAndHideIndicator()
        }
        
        guard let fromIndexPath = draggingIndexPath, let target = target else {
            resetAction()
            return
        }

        let delegate = delegate as? TPCollectionDragInsertReorderDelegate
        let newDraggingIndexPath = delegate?.collectionDragInsertReorder(self,
                                                                    inserItemTo: target.indexPath,
                                                                    from: fromIndexPath,
                                                                    depth: target.depth)
        if let indexPath = newDraggingIndexPath {
            self.changeDraggingIndexPath(indexPath)
        }
        
        resetAction()
    }
    
    // MARK: - update
    /// 清除目标索引并隐藏插入指示器
    private func clearTargetAndHideIndicator() {
        // 清除目标
        self.target = nil
        
        // 隐藏插入指示器
        self.insertIndicatorView.isHidden = true
        self.focusIndicatorView.isHidden = true
    }
    
    /// 更新指示视图和插入位置信息
    private func update(with touchPoint: CGPoint) {
        guard draggingIndexPath != nil,
              let indexPath = indexPathForItem(at: touchPoint),
              let cell = collectionView.cellForItem(at: indexPath) else {
            // 如果触摸点不在有效范围内
            clearTargetAndHideIndicator()
            return
        }
        
        let insertIndexPath = insertIndexPath(for: cell, at: indexPath, with: touchPoint)
        guard canInsertItem(to: insertIndexPath) else {
            // 如果无法插入行
            clearTargetAndHideIndicator()
            return
        }
        
        var shouldFlash = false
        let cellPoint = collectionView.convert(touchPoint, toViewOrWindow: cell)
        if cellPoint.y > cell.height * 0.25 && cellPoint.y < cell.height * 0.75 {
            shouldFlash = canFlashItem(at: indexPath)
        }
        
        if shouldFlash {
            clearTargetAndHideIndicator()
            if isMoving {
                monitor.resetIfNeeded(at: indexPath)
                monitor.start(at: indexPath)
                if highlightedIndexPath != indexPath {
                    unhighlight() /// 触摸索引非当前高亮索引，取消高亮
                }
                
                updateFlash(at: indexPath)
            } else {
                /// 当前已结束拖动排序
                unhighlight()
                monitor.reset()
            }
        } else {
            unhighlight()
            monitor.reset()
            updateIndicator(with: touchPoint, touchIndexPath: indexPath, cellFrame: cell.frame)
        }
    }
    
    /// 更新当前插入指示器
    func updateIndicator(with touchPoint: CGPoint,
                         touchIndexPath: IndexPath,
                         cellFrame: CGRect) {
        guard let draggingIndexPath = draggingIndexPath else {
            return
        }
        
        let lineSpacing = lineSpacing()
        var indicatorCenterY: CGFloat
        var insertPosition: InsertPosition
        if touchPoint.y >= cellFrame.midY {
            // 插入到当前cell下一行
            indicatorCenterY = cellFrame.maxY + lineSpacing / 2.0
            if indicatorCenterY >= collectionView.contentSize.height {
                indicatorCenterY = collectionView.contentSize.height - insertIndicatorView.halfHeight
            }
            
            insertPosition = .after
        } else {
            // 插入到当前cell上一行
            indicatorCenterY = cellFrame.minY - lineSpacing / 2.0
            if indicatorCenterY <= 0 {
                indicatorCenterY = insertIndicatorView.frame.size.height / 2
            }
            
            insertPosition = .before
        }
        

        var targetIndexPath = targetIndexPath(fromIndexPath: draggingIndexPath,
                                              touchIndexPath: touchIndexPath,
                                              insertPosition: insertPosition)
        if !canInsertItem(to: targetIndexPath) {
            /// 不可插入到目标索引
            targetIndexPath = draggingIndexPath
        }
        
        let depth = indentationLevel(for: targetIndexPath, touchPoint: touchPoint)
        self.target = (targetIndexPath, depth)
        
        /// 更新插入指示视图
        insertIndicatorView.indentationLevel = depth
        insertIndicatorView.frame = CGRect(x: cellFrame.minX,
                                           y: indicatorCenterY - indicatorHeight / 2.0,
                                           width: cellFrame.width,
                                           height: indicatorHeight)
        insertIndicatorView.isHidden = false
        
        /// 更新聚焦指示视图
        if let indexPath = focusIndexPath(for: targetIndexPath, depth: depth),
           let cell = collectionView.cellForItem(at: indexPath) {
            let frame = cell.convert(cell.bounds, toViewOrWindow: collectionView)
            focusIndicatorView.frame = frame
            focusIndicatorView.isHidden = false
        } else {
            focusIndicatorView.isHidden = true
        }
    }
    
    func updateFlash(at indexPath: IndexPath) {
        guard highlightedIndexPath != indexPath else {
                insertIndicatorView.isHidden = true
            return
        }
        
        highlightItem(at: indexPath)
        insertIndicatorView.isHidden = true
    }

    // MARK: - Highlight
    var highlightedIndexPath: IndexPath?
    func unhighlight() {
        guard let highlightedIndexPath = highlightedIndexPath else {
            return
        }

        let cell = collectionView.cellForItem(at: highlightedIndexPath)
        cell?.isHighlighted = false
        self.highlightedIndexPath = nil
    }
    
    func highlightItem(at indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.isHighlighted = false
        self.highlightedIndexPath = indexPath
    }
    
    // MARK: - 执行单元格闪烁动画
    func commitFlashing(at indexPath: IndexPath) {
        /// 取消高亮
        unhighlight()
        
        /// 执行闪烁动画
//        let cell = collectionView.cellForItem(at: indexPath)
//        cell?.startFlashing()
        
        /// 通知代理对象
        if let delegate = delegate as? TPCollectionDragInsertReorderDelegate,
           let sourceIndexPath = draggingIndexPath {
            delegate.collectionDragInsertReorder(self,
                                            didFlashItemAt: indexPath,
                                            from: sourceIndexPath)
        }
        
        update(with: currentPoint)
    }
    

    // MARK: - Helpers
    /// 获取目标索引处的指示器 levelIndex
    private func indentationLevel(for targetIndexPath: IndexPath, touchPoint: CGPoint) -> Int {
        guard let delegate = delegate as? TPCollectionDragInsertReorderDelegate,
              let sourceIndexPath = draggingIndexPath else {
            return 0
        }
        
        let ratio = validatedRatio(touchPoint.x / collectionView.frame.width)
        return delegate.collectionDragInsertReorder(self,
                                               indentationLevelTo: targetIndexPath,
                                               from: sourceIndexPath,
                                               ratio: ratio)
    }
    
    private func focusIndexPath(for targetIndexPath: IndexPath, depth: Int) -> IndexPath? {
        guard let delegate = delegate as? TPCollectionDragInsertReorderDelegate,
              let sourceIndexPath = draggingIndexPath else {
            return nil
        }
        
        return delegate.collectionDragInsertReorder(self,
                                               focusIndexPathTo: targetIndexPath,
                                               from: sourceIndexPath,
                                               depth: depth)
    }
    
    
    /// 根据触摸点获取插入索引
    private func insertIndexPath(for cell: UICollectionViewCell,
                                 at indexPath: IndexPath,
                                 with touchPoint: CGPoint) -> IndexPath {
        var position: InsertPosition = .before
        if touchPoint.y >= cell.frame.midY {
            position = .after
        }
        
        let targetIndexPath = targetIndexPath(fromIndexPath: draggingIndexPath!,
                                              touchIndexPath: indexPath,
                                              insertPosition: position)
        return targetIndexPath
    }
    
    
    /// 获取目标索引
    private func targetIndexPath(fromIndexPath: IndexPath,
                                 touchIndexPath: IndexPath?,
                                 insertPosition: InsertPosition) -> IndexPath {
        guard let touchIndexPath = touchIndexPath else {
            return fromIndexPath
        }

        var targetIndexPath = touchIndexPath
        if insertPosition == .before {
            if fromIndexPath.section == touchIndexPath.section && fromIndexPath.row < touchIndexPath.row {
                targetIndexPath = IndexPath(row: touchIndexPath.row - 1, section: touchIndexPath.section)
            }
        } else {
            if fromIndexPath.section != touchIndexPath.section ||
               fromIndexPath.row > touchIndexPath.row {
                targetIndexPath = IndexPath(row: touchIndexPath.row + 1, section: touchIndexPath.section)
            }
        }

        return targetIndexPath
    }

    // MARK: - Helpers
    func lineSpacing() -> CGFloat {
        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return 0.0
        }
        
        return layout.minimumLineSpacing
    }

    func indexPathForItem(at point: CGPoint) -> IndexPath? {
        if let indexPath = collectionView.indexPathForItem(at: point) {
            return indexPath
        }
        
        let lineSpacing = lineSpacing()
        let topPoint = CGPoint(x: point.x, y: point.y - lineSpacing * 0.5)
        if let indexPath = collectionView.indexPathForItem(at: topPoint) {
            return indexPath
        }
        
        let bottomPoint = CGPoint(x: point.x, y: point.y + lineSpacing * 0.5)
        let indexPath = collectionView.indexPathForItem(at: bottomPoint)
        return indexPath
    }
    
    // MARK: - Delegate Helpers
    private func canFlashItem(at indexPath: IndexPath) -> Bool {
        guard let sourceIndexPath = draggingIndexPath,
              sourceIndexPath != indexPath,
              let delegate = delegate as? TPCollectionDragInsertReorderDelegate else {
            return false
        }
        
        return delegate.collectionDragInsertReorder(self,
                                               canFlashItemAt: indexPath,
                                               from: sourceIndexPath)
    }
    
    private func canInsertItem(to indexPath: IndexPath) -> Bool {
        if indexPath == draggingIndexPath {
            return true
        }

        if let delegate = delegate as? TPCollectionDragInsertReorderDelegate,
           let sourceIndexPath = draggingIndexPath {
            return delegate.collectionDragInsertReorder(self,
                                                   canInsertItemTo: indexPath,
                                                   from: sourceIndexPath)
        }

        return false
    }
    
    /// 验证触摸因子
    private func validatedRatio(_ ratio: CGFloat) -> CGFloat {
        var value: CGFloat
        let edgeValue = 0.25
        if ratio <= edgeValue {
            value = 0.0
        } else if ratio >= 1.0 - edgeValue {
            value = 1.0
        } else {
            value = (ratio - edgeValue) / (1.0 - 2 * edgeValue)
        }
        
        return value
    }
}
