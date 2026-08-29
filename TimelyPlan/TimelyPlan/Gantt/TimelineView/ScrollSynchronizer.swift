//
//  ScrollSynchronizer.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/24.
//

import Foundation
import UIKit

// MARK: - 滚动事件协议

/// 横向滚动事件协议，由滚动视图在滚动时主动调用
protocol HorizontalScrollSyncDelegate: AnyObject {
    /// 横向滚动视图内容偏移发生变化
    /// - Parameters:
    ///   - scrollView: 发生滚动的视图
    ///   - xOffset: 新的水平偏移量
    func horizontalScrollSyncView(_ scrollView: AnyObject, didChangeXOffset xOffset: CGFloat)
    
    /// 横向滚动视图开始滚动
    func horizontalScrollSyncViewWillBeginScrolling(_ scrollView: AnyObject)
    
    /// 横向滚动视图结束滚动
    func horizontalScrollSyncViewDidEndScrolling(_ scrollView: AnyObject)
}

/// 垂直滚动事件协议，由滚动视图在滚动时主动调用
protocol VerticalScrollSyncDelegate: AnyObject {
    /// 垂直滚动视图内容偏移发生变化
    /// - Parameters:
    ///   - scrollView: 发生滚动的视图
    ///   - yOffset: 新的垂直偏移量
    func verticalScrollSyncView(_ scrollView: AnyObject, didChangeYOffset yOffset: CGFloat)
    
    /// 垂直滚动视图开始滚动
    func verticalScrollSyncViewWillBeginScrolling(_ scrollView: AnyObject)
    
    /// 垂直滚动视图结束滚动
    func verticalScrollSyncViewDidEndScrolling(_ scrollView: AnyObject)
}

// MARK: - 横向滚动同步协议

/// 横向滚动同步协议，任何需要参与横向滚动同步的视图都需要遵循此协议
protocol HorizontalScrollSyncable: AnyObject {
    /// 水平内容偏移
    var xOffset: CGFloat { get set }
    
    /// 设置水平内容偏移
    func setXOffset(_ xOffset: CGFloat, animated: Bool)
    
    /// 横向滚动同步代理
    var horizontalScrollSyncDelegate: HorizontalScrollSyncDelegate? { get set }
    
    /// 通知横向滚动开始（由视图内部调用）
    func notifyHorizontalScrollWillBegin()
    
    /// 通知横向滚动结束（由视图内部调用）
    func notifyHorizontalScrollDidEnd()
    
    /// 通知横向内容偏移变化（由视图内部调用）
    func notifyHorizontalContentOffsetChanged()
}

// MARK: - 垂直滚动同步协议

/// 垂直滚动同步协议，任何需要参与垂直滚动同步的视图都需要遵循此协议
protocol VerticalScrollSyncable: AnyObject {
    /// 垂直内容偏移
    var yOffset: CGFloat { get set }
    
    /// 设置垂直内容偏移
    func setYOffset(_ yOffset: CGFloat, animated: Bool)
    
    /// 垂直滚动同步代理
    var verticalScrollSyncDelegate: VerticalScrollSyncDelegate? { get set }
    
    /// 通知垂直滚动开始（由视图内部调用）
    func notifyVerticalScrollWillBegin()
    
    /// 通知垂直滚动结束（由视图内部调用）
    func notifyVerticalScrollDidEnd()
    
    /// 通知垂直内容偏移变化（由视图内部调用）
    func notifyVerticalContentOffsetChanged()
}

// MARK: - HorizontalScrollSyncable 协议默认实现

extension HorizontalScrollSyncable {
    func notifyHorizontalScrollWillBegin() {
        horizontalScrollSyncDelegate?.horizontalScrollSyncViewWillBeginScrolling(self)
    }
    
    func notifyHorizontalScrollDidEnd() {
        horizontalScrollSyncDelegate?.horizontalScrollSyncViewDidEndScrolling(self)
    }
    
    func notifyHorizontalContentOffsetChanged() {
        horizontalScrollSyncDelegate?.horizontalScrollSyncView(self, didChangeXOffset: xOffset)
    }
}

// MARK: - VerticalScrollSyncable 协议默认实现

extension VerticalScrollSyncable {
    func notifyVerticalScrollWillBegin() {
        verticalScrollSyncDelegate?.verticalScrollSyncViewWillBeginScrolling(self)
    }
    
    func notifyVerticalScrollDidEnd() {
        verticalScrollSyncDelegate?.verticalScrollSyncViewDidEndScrolling(self)
    }
    
    func notifyVerticalContentOffsetChanged() {
        verticalScrollSyncDelegate?.verticalScrollSyncView(self, didChangeYOffset: yOffset)
    }
}

// MARK: - 关联对象键

private enum AssociatedKeys {
    static var horizontalScrollSyncDelegate = "horizontalScrollSyncDelegate"
    static var verticalScrollSyncDelegate = "verticalScrollSyncDelegate"
}

// MARK: - UIScrollView 扩展

extension UIScrollView: HorizontalScrollSyncable, VerticalScrollSyncable {
    var xOffset: CGFloat {
        get {
            return contentOffset.x
        }
        set {
            contentOffset = CGPoint(x: newValue, y: contentOffset.y)
        }
    }
    
    func setXOffset(_ xOffset: CGFloat, animated: Bool) {
        setContentOffset(CGPoint(x: xOffset, y: contentOffset.y), animated: animated)
    }
    
    var yOffset: CGFloat {
        get {
            return contentOffset.y
        }
        set {
            contentOffset = CGPoint(x: contentOffset.x, y: newValue)
        }
    }
    
    func setYOffset(_ yOffset: CGFloat, animated: Bool) {
        setContentOffset(CGPoint(x: contentOffset.x, y: yOffset), animated: animated)
    }
    
    var horizontalScrollSyncDelegate: HorizontalScrollSyncDelegate? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.horizontalScrollSyncDelegate) as? HorizontalScrollSyncDelegate
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.horizontalScrollSyncDelegate, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    var verticalScrollSyncDelegate: VerticalScrollSyncDelegate? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.verticalScrollSyncDelegate) as? VerticalScrollSyncDelegate
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.verticalScrollSyncDelegate, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

// MARK: - 横向滚动同步器

/// 横向滚动同步器，负责同步多个遵循 HorizontalScrollSyncable 协议的视图的 X 偏移
final class HorizontalScrollSynchronizer: HorizontalScrollSyncDelegate {
    
    // MARK: - 私有属性
    
    /// 当前水平偏移量
    private var currentXOffset: CGFloat = 0
    
    /// 弱引用集合，存储所有参与同步的视图
    private var syncableViews = NSHashTable<AnyObject>.weakObjects()
    
    /// 当前正在滚动的视图（用于避免循环同步）
    private weak var scrollingView: AnyObject?
    
    /// 是否正在同步中（防止递归）
    private var isSynchronizing = false
    
    // MARK: - 公开方法
    
    /// 添加需要同步的视图
    /// - Parameter view: 遵循 HorizontalScrollSyncable 协议的视图
    func addSyncableView<T: HorizontalScrollSyncable>(_ view: T) {
        let object = view as AnyObject
        
        // 检查是否已存在
        if !syncableViews.contains(object) {
            // 初始化新添加视图的 X 偏移
            view.xOffset = currentXOffset
            syncableViews.add(object)
            
            // 设置横向滚动同步代理
            view.horizontalScrollSyncDelegate = self
        } else {
            // 已存在则更新 X 偏移
            view.xOffset = currentXOffset
        }
    }
    
    /// 移除视图
    /// - Parameter view: 需要移除的视图
    func removeSyncableView<T: HorizontalScrollSyncable>(_ view: T) {
        let object = view as AnyObject
        
        // 清除横向滚动同步代理
        if view.horizontalScrollSyncDelegate === self {
            view.horizontalScrollSyncDelegate = nil
        }
        
        syncableViews.remove(object)
    }
    
    /// 移除所有视图
    func removeAllSyncableViews() {
        for object in syncableViews.allObjects {
            if let syncableView = object as? HorizontalScrollSyncable,
               syncableView.horizontalScrollSyncDelegate === self {
                syncableView.horizontalScrollSyncDelegate = nil
            }
        }
        syncableViews.removeAllObjects()
    }
    
    /// 设置水平偏移量
    /// - Parameters:
    ///   - xOffset: 目标水平偏移量
    ///   - animated: 是否动画
    func setXOffset(_ xOffset: CGFloat, animated: Bool = false) {
        currentXOffset = xOffset
        synchronize(animated: animated, excluding: nil)
    }
    
    /// 获取当前水平偏移量
    var xOffset: CGFloat {
        return currentXOffset
    }
    
    // MARK: - 私有方法
    
    /// 同步所有视图的 X 偏移量
    /// - Parameters:
    ///   - animated: 是否动画
    ///   - excludingView: 需要排除的视图（通常是触发滚动的视图）
    private func synchronize(animated: Bool = false, excluding excludedView: AnyObject?) {
        // 防止递归同步
        guard !isSynchronizing else { return }
        
        isSynchronizing = true
        defer { isSynchronizing = false }
        
        for object in syncableViews.allObjects {
            // 跳过需要排除的视图
            if object === excludedView {
                continue
            }
            
            if let syncableView = object as? HorizontalScrollSyncable {
                if animated {
                    syncableView.setXOffset(currentXOffset, animated: animated)
                } else {
                    syncableView.xOffset = currentXOffset
                }
            }
        }
    }
    
    // MARK: - HorizontalScrollSyncDelegate 实现
    
    func horizontalScrollSyncView(_ scrollView: AnyObject, didChangeXOffset xOffset: CGFloat) {
        // 记录当前滚动的视图
        scrollingView = scrollView
        currentXOffset = xOffset
        
        // 同步其他视图
        synchronize(excluding: scrollView)
    }
    
    func horizontalScrollSyncViewWillBeginScrolling(_ scrollView: AnyObject) {
        scrollingView = scrollView
    }
    
    func horizontalScrollSyncViewDidEndScrolling(_ scrollView: AnyObject) {
        if scrollingView === scrollView {
            scrollingView = nil
        }
    }
}

// MARK: - 垂直滚动同步器

/// 垂直滚动同步器，负责同步多个遵循 VerticalScrollSyncable 协议的视图的 Y 偏移
final class VerticalScrollSynchronizer: VerticalScrollSyncDelegate {
    
    // MARK: - 私有属性
    
    /// 当前垂直偏移量
    private var currentYOffset: CGFloat = 0
    
    /// 弱引用集合，存储所有参与同步的视图
    private var syncableViews = NSHashTable<AnyObject>.weakObjects()
    
    /// 当前正在滚动的视图（用于避免循环同步）
    private weak var scrollingView: AnyObject?
    
    /// 是否正在同步中（防止递归）
    private var isSynchronizing = false
    
    // MARK: - 公开方法
    
    /// 添加需要同步的视图
    /// - Parameter view: 遵循 VerticalScrollSyncable 协议的视图
    func addSyncableView<T: VerticalScrollSyncable>(_ view: T) {
        let object = view as AnyObject
        
        // 检查是否已存在
        if !syncableViews.contains(object) {
            // 初始化新添加视图的 Y 偏移
            view.yOffset = currentYOffset
            syncableViews.add(object)
            
            // 设置垂直滚动同步代理
            view.verticalScrollSyncDelegate = self
        } else {
            // 已存在则更新 Y 偏移
            view.yOffset = currentYOffset
        }
    }
    
    /// 移除视图
    /// - Parameter view: 需要移除的视图
    func removeSyncableView<T: VerticalScrollSyncable>(_ view: T) {
        let object = view as AnyObject
        
        // 清除垂直滚动同步代理
        if view.verticalScrollSyncDelegate === self {
            view.verticalScrollSyncDelegate = nil
        }
        
        syncableViews.remove(object)
    }
    
    /// 移除所有视图
    func removeAllSyncableViews() {
        for object in syncableViews.allObjects {
            if let syncableView = object as? VerticalScrollSyncable,
               syncableView.verticalScrollSyncDelegate === self {
                syncableView.verticalScrollSyncDelegate = nil
            }
        }
        syncableViews.removeAllObjects()
    }
    
    /// 设置垂直偏移量
    /// - Parameters:
    ///   - yOffset: 目标垂直偏移量
    ///   - animated: 是否动画
    func setYOffset(_ yOffset: CGFloat, animated: Bool = false) {
        currentYOffset = yOffset
        synchronize(animated: animated, excluding: nil)
    }
    
    /// 获取当前垂直偏移量
    var yOffset: CGFloat {
        return currentYOffset
    }
    
    // MARK: - 私有方法
    
    /// 同步所有视图的 Y 偏移量
    /// - Parameters:
    ///   - animated: 是否动画
    ///   - excludingView: 需要排除的视图（通常是触发滚动的视图）
    private func synchronize(animated: Bool = false, excluding excludedView: AnyObject?) {
        // 防止递归同步
        guard !isSynchronizing else { return }
        
        isSynchronizing = true
        defer { isSynchronizing = false }
        
        for object in syncableViews.allObjects {
            // 跳过需要排除的视图
            if object === excludedView {
                continue
            }
            
            if let syncableView = object as? VerticalScrollSyncable {
                if animated {
                    syncableView.setYOffset(currentYOffset, animated: animated)
                } else {
                    syncableView.yOffset = currentYOffset
                }
            }
        }
    }
    
    // MARK: - VerticalScrollSyncDelegate 实现
    
    func verticalScrollSyncView(_ scrollView: AnyObject, didChangeYOffset yOffset: CGFloat) {
        // 记录当前滚动的视图
        scrollingView = scrollView
        currentYOffset = yOffset
        
        // 同步其他视图
        synchronize(excluding: scrollView)
    }
    
    func verticalScrollSyncViewWillBeginScrolling(_ scrollView: AnyObject) {
        scrollingView = scrollView
    }
    
    func verticalScrollSyncViewDidEndScrolling(_ scrollView: AnyObject) {
        if scrollingView === scrollView {
            scrollingView = nil
        }
    }
}
