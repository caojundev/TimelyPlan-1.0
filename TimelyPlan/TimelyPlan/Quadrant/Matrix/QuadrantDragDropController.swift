//
//  QuadrantDragDropController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/22.
//

import Foundation
import UIKit

struct QuadrantIndexPath {
    
    /// 象限
    var quadrant: Quadrant
    
    /// 索引
    var indexPath: IndexPath
}

protocol QuadrantDragDropControllerDelegate: AnyObject {
    
    func quadrantDragDropController(_ controller: QuadrantDragDropController, canMoveItemAt indexPath: QuadrantIndexPath) -> Bool
    
    func quadrantDragDropController(_ controller: QuadrantDragDropController, canMoveItemTo quadrant: Quadrant) -> Bool

    func quadrantDragDropController(_ controller: QuadrantDragDropController,
                                    moveItemAt indexPath: QuadrantIndexPath,
                                    to quadrant: Quadrant)

}

class QuadrantDragDropController: NSObject, UIGestureRecognizerDelegate {

    /// 代理对象
    weak var delegate: QuadrantDragDropControllerDelegate?

    /// 是否可用
    var isEnabled: Bool {
        get {
            return longPressGesture.isEnabled
        }
        
        set {
            longPressGesture.isEnabled = newValue
        }
    }

    /// 圆角半径
    var draggingViewCornerRadius: CGFloat = 0.0
    
    /// 列表视图
    private(set) var matrixView: QuadrantMatrixView
    
    /// 长按手势
    private var longPressGesture: UILongPressGestureRecognizer!
    
    /// 是否移动中
    private(set) var isMoving: Bool = false

    /// 当前触摸点位置
    private(set) var currentPoint = CGPoint.zero
    
    /// 拖动视图
    private(set) var draggingView: UIView?
    
    /// 当前拖动任务象限索引信息
    private(set) var draggingIndexPath: QuadrantIndexPath?
    
    init(matrixView: QuadrantMatrixView) {
        self.matrixView = matrixView
        super.init()
        self.longPressGesture = UILongPressGestureRecognizer(target: self,
                                                             action: #selector(handleLongPress(_:)))
        self.longPressGesture.allowableMovement = 5.0
        self.longPressGesture.delegate = self
        self.matrixView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        self.currentPoint = recognizer.location(in: matrixView)
        switch recognizer.state {
        case .began:
            matrixView.endEditing(true)
            
            guard let indexPath = matrixView.indexPathForItem(at: self.currentPoint), canMoveItem(at: indexPath) else {
                        return
            }
            
            self.draggingIndexPath = indexPath
            self.matrixView.isUserInteractionEnabled = false
            self.draggingDidBegin(at: currentPoint)
            
            let draggingCell = matrixView.cellForItem(at: indexPath)
            guard let draggingCell = draggingCell, let draggingCellSuperView = draggingCell.superview, let rootView = UIWindow.keyWindow else {
                        return
            }
            
            draggingCell.isHighlighted = false
            draggingView = draggingCell.tp_snapshotView(cornerRadius: draggingViewCornerRadius)
            draggingView?.center = draggingCellSuperView.convert(draggingCell.center, toViewOrWindow: rootView)
            if let draggingView = draggingView {
                rootView.addSubview(draggingView)
            }
            
            draggingCell.isHidden = true
            let center = matrixView.convert(currentPoint, toViewOrWindow: draggingView?.superview)
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

            let center = matrixView.convert(currentPoint, toViewOrWindow: draggingView?.superview)
            self.draggingView?.center = center
            self.draggingDidChange(at: currentPoint)
        default:
            self.isMoving = false
            self.draggingDidEnd(at: currentPoint)
            self.matrixView.isUserInteractionEnabled = true
        }
    }
    
    func draggingDidBegin(at point: CGPoint) {
        // Custom logic
    }
    
    var targetQuadrantView: QuadrantView?

    func draggingDidChange(at point: CGPoint) {
        setHidden(true, forItemAt: draggingIndexPath)
        
        let quadrantView = matrixView.quadrantView(at: point)
        guard let quadrantView = quadrantView,
              quadrantView.quadrant != draggingIndexPath?.quadrant,
              canMoveItem(to: quadrantView.quadrant) else {
            resetTargetQuadrantView()
            return
        }

        if targetQuadrantView != quadrantView {
            TPImpactFeedback.impactWithSoftStyle()
            targetQuadrantView?.isHighlighted = false
            targetQuadrantView = quadrantView
            targetQuadrantView?.isHighlighted = true
        }
    }
    
    func draggingDidEnd(at point: CGPoint) {
        let sourceIndexPath = draggingIndexPath
        if let indexPath = draggingIndexPath {
            setHidden(false, forItemAt: indexPath)
        }
        
        var targetQuadrant: Quadrant?
        if let targetQuadrantView = targetQuadrantView {
            targetQuadrant = targetQuadrantView.quadrant
            resetTargetQuadrantView()
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut) {
            self.draggingView?.alpha = 0.0
            self.draggingView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            self.draggingIndexPath = nil
            self.draggingView?.removeFromSuperview()
            self.draggingView = nil
        }
        
        if let sourceIndexPath = sourceIndexPath, let targetQuadrant = targetQuadrant {
            delegate?.quadrantDragDropController(self, moveItemAt: sourceIndexPath, to: targetQuadrant)
        }
    }
    
    private func resetTargetQuadrantView() {
        targetQuadrantView?.isHighlighted = false
        targetQuadrantView = nil
    }
    
    // MARK: -
    
    func stopDragging() {
        if !isMoving {
            return
        }

        if let draggingIndexPath = draggingIndexPath {
            setHidden(false, forItemAt: draggingIndexPath)
        }

        draggingIndexPath = nil
        draggingView?.removeFromSuperview()
        draggingView = nil
        longPressGesture.isEnabled = false
        longPressGesture.isEnabled = true
    }
    
    /// 显示/隐藏索引处的单元格
    func setHidden(_ isHidden: Bool, forItemAt indexPath: QuadrantIndexPath?) {
        guard let indexPath = indexPath else {
            return
        }
        
        if let cell = matrixView.cellForItem(at: indexPath) {
            cell.isHidden = isHidden
        }
    }
    
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    // MARK: - Helpers
    
    private func canMoveItem(at indexPath: QuadrantIndexPath) -> Bool {
        return delegate?.quadrantDragDropController(self, canMoveItemAt: indexPath) ?? false
    }
    
    private func canMoveItem(to quadrant: Quadrant) -> Bool {
        return delegate?.quadrantDragDropController(self, canMoveItemTo: quadrant) ?? false
    }
    
}
