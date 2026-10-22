//
//  SkeletonLayoutMonitor.swift
//  Skeleton
//
//  任何视图的 layoutSubviews 结束时，只要它是某个骨架目标的自身或子孙，
//  就把对应骨架标记为“待重算”，由骨架自己的 layoutSubviews 统一绘制。
//
//  成本：没有骨架时监控器为 0 开销（只有一个 Bool + 空集合判断）；
//  有骨架时每次 layoutSubviews 多一次“沿 superview 链查找”的开销（O(深度)）。
//

import UIKit

enum SkeletonLayoutMonitor {

    private static let hosts = NSHashTable<SkeletonHostView>.weakObjects()
    
    static var hasActiveHosts: Bool { hosts.count > 0 }

    static func register(_ host: SkeletonHostView) {
        hosts.add(host)
    }

    static func unregister(_ host: SkeletonHostView) {
        hosts.remove(host)
    }

    static func layoutDidOccur(in view: UIView) {
        guard hasActiveHosts else { return }
        for host in hosts.allObjects {
            guard let target = host.target else { continue }
            if view === target || view.isDescendant(of: target) {
                host.setNeedsRebuild()
            }
        }
    }
}

extension UIView {

    /// 骨架布局
    @objc func sk_layoutSubviews() {
        guard SkeletonLayoutMonitor.hasActiveHosts else { return }
        // 骨架自身布局时不要再触发自己
        guard !(self is SkeletonHostView) else { return }
        SkeletonLayoutMonitor.layoutDidOccur(in: self)
    }
}
