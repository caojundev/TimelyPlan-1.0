//
//  TPCollectionDragExchangeReorder.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/20.
//

import Foundation

protocol TPCollectionDragExchangeReorderDelegate: TPCollectionDragReorderDelegate {
    
    func collectionDragExchangeReorder(_ reorder: TPCollectionDragExchangeReorder,
                                       canMoveItemFrom fromIndexPath: IndexPath,
                                       to toIndexPath: IndexPath) -> Bool
    
    func collectionDragExchangeReorder(_ reorder: TPCollectionDragExchangeReorder,
                                       moveItemFrom fromIndexPath: IndexPath,
                                       to toIndexPath: IndexPath) -> Bool
}

class TPCollectionDragExchangeReorder: TPCollectionDragReorder {
    
    var previousIndexPath: IndexPath?
    
    override func draggingDidBegin(at point: CGPoint) {
        super.draggingDidBegin(at: point)
        previousIndexPath = draggingIndexPath
    }
    
    override func draggingDidChange(at point: CGPoint) {
        super.draggingDidChange(at: point)
        if !isAutoScrolling() {
            update(with: point)
        }
    }

    override func draggingDidEnd(at point: CGPoint) {
        super.draggingDidEnd(at: point)
        self.previousIndexPath = nil
        resetDraggingView(at: draggingIndexPath)
    }
    
    func update(with touchPoint: CGPoint) {
        let touchIndexPath = collectionView.indexPathForItem(at: touchPoint)
        if touchIndexPath == nil || touchIndexPath != previousIndexPath {
            self.previousIndexPath = nil
        }
        
        guard let fromIndexPath = draggingIndexPath,
              let toIndexPath = touchIndexPath,
              fromIndexPath != toIndexPath,
              toIndexPath != previousIndexPath,
              canMoveItem(from: fromIndexPath, to: toIndexPath) else {
            return
        }
        
        let success = moveItem(from: fromIndexPath, to: toIndexPath)
        if success {
            previousIndexPath = fromIndexPath
            
            /// 设置新的拖动索引路径为当前触摸索引路径
            changeDraggingIndexPath(toIndexPath)
        }
    }
    
    // MARK: - Helpers
    private func canMoveItem(from fromIndexPath: IndexPath, to toIndexPath: IndexPath) -> Bool {
        if let delegate = delegate as? TPCollectionDragExchangeReorderDelegate {
            return delegate.collectionDragExchangeReorder(self,
                                                          canMoveItemFrom: fromIndexPath,
                                                          to: toIndexPath)
        }
        
        return false
    }
    
    private func moveItem(from fromIndexPath: IndexPath, to toIndexPath: IndexPath) -> Bool {
        if let delegate = delegate as? TPCollectionDragExchangeReorderDelegate {
            return delegate.collectionDragExchangeReorder(self,
                                                          moveItemFrom: fromIndexPath,
                                                          to: toIndexPath)
        }
        
        return false
    }
}
