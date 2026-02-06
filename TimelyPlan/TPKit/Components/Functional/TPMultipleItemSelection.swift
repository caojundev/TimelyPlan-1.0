//
//  TPMultipleItemSelection.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/10.
//

import Foundation

protocol TPMultipleItemSelectionDelegate: AnyObject {
    
    /// 是否可以选中条目
    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, canSelectItem item: T) -> Bool

    /// 是否可以反选条目
    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, canDeselectItem item: T) -> Bool

    /// 选中条目
    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, didSelectItem item: T)

    /// 反选条目
    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, didDeselectItem item: T)
}

protocol TPMultipleItemSelectionUpdater: AnyObject {
    
    /// 通知Updater选中条目发生改变
    func multipleItemSelectionDidChange<T>(inserts: Set<T>?, deletes: Set<T>?)
}

class TPMultipleItemSelection<T: Hashable>: NSObject {
    
    /// 代理对象
    weak var delegate: TPMultipleItemSelectionDelegate?
    
    /// 选中条目
    private(set) var selectedItems: Set<T> = []

    convenience init(items: [T]) {
        self.init()
        selectedItems = Set(items)
    }

    /// 选中条目数
    var selectedCount: Int {
        return selectedItems.count
    }

    func canSelectItem(_ item: T) -> Bool {
        return delegate?.multipleItemSelection(self, canSelectItem: item) ?? true
    }

    func canDeselectItem(_ item: T) -> Bool {
        return delegate?.multipleItemSelection(self, canDeselectItem: item) ?? true
    }

    private func didSelectItem(_ item: T) {
        delegate?.multipleItemSelection(self, didSelectItem: item)
    }

    private func didDeselectItem(_ item: T) {
        delegate?.multipleItemSelection(self, didDeselectItem: item)
    }

    func isSelectedItem(_ item: T) -> Bool {
        return selectedItems.contains(item)
    }
    
    func selectItem(_ item: T, autoDeselect: Bool = true) {
        if isSelectedItem(item) {
            /// 反选
            if autoDeselect && canDeselectItem(item) {
                selectedItems.remove(item)
                didDeselectItem(item)
                notifyUpdaters(inserts: nil, deletes: [item])
            }
        } else {
            /// 选择该条目
            if canSelectItem(item) {
                selectedItems.insert(item)
                didSelectItem(item)
                notifyUpdaters(inserts: [item], deletes: nil)
            }
        }
    }

    func deselectItem(_ item: T) {
        if selectedItems.contains(item) {
            selectedItems.remove(item)
            didDeselectItem(item)
            notifyUpdaters(inserts: nil, deletes: [item])
        }
    }
    
    /// 选中数组中的条目
    func selectItems(_ items: [T]) {
        let oldItems = selectedItems
        var insertItems = Set<T>()
        for item in items {
            if canSelectItem(item) {
                insertItems.insert(item)
            }
        }
        
        selectedItems.formUnion(insertItems)
        notifyUpdaters(oldItems: oldItems)
    }
    
    /// 取消选中数组中的条目
    func deselectItems(_ items: [T]) {
        let oldItems = selectedItems
        var deleteItems = Set<T>()
        for item in items {
            if canDeselectItem(item) {
                deleteItems.insert(item)
            }
        }
        
        selectedItems.subtract(deleteItems)
        notifyUpdaters(oldItems: oldItems)
    }
    
    /// 设置选中条目
    func setSelectedItems(_ items: Set<T>?) {
        guard selectedItems != items else {
            return
        }
        
        let oldItems = selectedItems
        if let items = items {
            selectedItems = items
        } else {
            selectedItems = Set<T>()
        }
        
        notifyUpdaters(oldItems: oldItems)
    }
    
    /// 重置选中条目，不通知 updater 以及 delegate
    func reset(with items: [T]? = nil) {
        let items = items ?? []
        selectedItems = Set(items)
    }

    // MARK: - updater
    func addUpdater(_ updater: TPMultipleItemSelectionUpdater) {
        addDelegate(updater)
    }
    
    /// 通知Updater选中条目发生改变
    func notifyUpdaters(inserts: Set<T>?, deletes: Set<T>?) {
        notifyDelegates { (updater: TPMultipleItemSelectionUpdater) in
            updater.multipleItemSelectionDidChange(inserts: inserts, deletes: deletes)
        }
    }
    
    func notifyUpdaters(oldItems: Set<T>) {
        let previousItems = oldItems
        let currentItems = selectedItems
        let insertedItems = currentItems.subtracting(previousItems)
        let removedItems = previousItems.subtracting(currentItems)
        notifyUpdaters(inserts: insertedItems.count > 0 ? insertedItems : nil,
                       deletes: removedItems.count > 0 ? removedItems : nil)
    }
}
