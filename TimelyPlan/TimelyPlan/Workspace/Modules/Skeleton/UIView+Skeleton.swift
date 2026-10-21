//
//  UIView+Skeleton.swift
//  Skeleton
//
//  对外 API：标记属性 + `view.sk.show()` 一行式调用。
//  所有附加状态都放在关联对象里，不给业务类增加任何存储属性或父类。
//

import Foundation
import UIKit

// MARK: - 关联对象存储

/// 挂在单个 UIView 上的骨架属性
final class SkeletonAttributes {
    /// 是否作为占位块
    var isSkeletonable = false
    /// 是否在骨架期间排除（例如分隔线、装饰元素）
    var isExcluded = false
    /// 单独指定圆角，nil 表示跟随 config / layer
    var cornerRadius: CGFloat?
    /// 单独指定形状
    var shape: SkeletonConfig.Shape = .auto
    /// 单独指定内缩
    var insets: UIEdgeInsets = .zero
}

private var skeletonAttributesKey: UInt8 = 0
private var skeletonHostKey: UInt8 = 0

extension UIView {

    /// 懒加载，读取时才创建（内部遍历请用 `skAttributesIfLoaded`，避免给全树的 view 都挂对象）
    var skAttributes: SkeletonAttributes {
        if let existing = objc_getAssociatedObject(self, &skeletonAttributesKey) as? SkeletonAttributes {
            return existing
        }
        let attributes = SkeletonAttributes()
        objc_setAssociatedObject(self, &skeletonAttributesKey, attributes, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return attributes
    }

    var skAttributesIfLoaded: SkeletonAttributes? {
        objc_getAssociatedObject(self, &skeletonAttributesKey) as? SkeletonAttributes
    }

    /// 当前挂着的骨架视图
    var skHost: SkeletonHostView? {
        get { objc_getAssociatedObject(self, &skeletonHostKey) as? SkeletonHostView }
        set { objc_setAssociatedObject(self, &skeletonHostKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

// MARK: - 标记属性

public extension UIView {

    /// 标记该视图需要被骨架化。遍历时**不再**深入它的子视图（形成一个整块）。
    ///
    /// ```
    /// avatarView.isSkeletonable = true
    /// ```
    var isSkeletonable: Bool {
        get { skAttributes.isSkeletonable }
        set { skAttributes.isSkeletonable = newValue }
    }

    /// 在骨架期间排除该视图及其子树（优先级高于 isSkeletonable）
    var isSkeletonExcluded: Bool {
        get { skAttributes.isExcluded }
        set { skAttributes.isExcluded = newValue }
    }

    /// 单独指定占位块形状
    var skeletonShape: SkeletonConfig.Shape {
        get { skAttributes.shape }
        set { skAttributes.shape = newValue }
    }

    /// 单独指定占位块圆角；设为 nil 恢复自动推断
    var skeletonCornerRadius: CGFloat? {
        get { skAttributes.cornerRadius }
        set { skAttributes.cornerRadius = newValue }
    }

    /// 单独指定占位块内缩
    var skeletonInsets: UIEdgeInsets {
        get { skAttributes.insets }
        set { skAttributes.insets = newValue }
    }
}

// MARK: - 命名空间

public struct SkeletonWrapper<Base> {
    public let base: Base
    init(_ base: Base) { self.base = base }
}

public protocol SkeletonNamespaceProvider {}

public extension SkeletonNamespaceProvider {
    var sk: SkeletonWrapper<Self> { SkeletonWrapper(self) }
}

extension UIView: SkeletonNamespaceProvider {}

// MARK: - 一行式 API

public extension SkeletonWrapper where Base: UIView {

    /// 显示骨架（一行代码）
    ///
    /// ```
    /// profileCard.sk.show()
    /// ```
    /// - Parameter config: 本次使用的配置，默认取 `Skeleton.config`
    /// - Returns: 生成并已安装的骨架视图，一般不需要持有
    @discardableResult
    func show(config: SkeletonConfig = Skeleton.config) -> SkeletonHostView {
        Skeleton.assertMainThread()

        // 已经显示：只更新配置并重算
        if let existing = base.skHost {
            existing.update(config: config)
            existing.refresh()
            return existing
        }

        // 先把待显示的布局跑完，保证第一次就能拿到正确的 frame
        if base.bounds.width > 0, base.bounds.height > 0 {
            base.layoutIfNeeded()
        }

        let host = SkeletonHostView(target: base, config: config)
        base.skHost = host
        host.install()          // 内部负责 addSubview、注册布局监听、首次绘制
        return host
    }

    /// 隐藏并移除骨架
    /// - Parameter animated: 是否淡出
    func hide(animated: Bool = false) {
        Skeleton.assertMainThread()
        guard let host = base.skHost else { return }

        guard animated else {
            host.remove()
            return
        }
        UIView.animate(withDuration: 0.18, animations: {
            host.alpha = 0
        }, completion: { _ in
            host.remove()
        })
    }

    /// 当前是否正在显示骨架
    var isShowing: Bool { base.skHost != nil }

    /// 强制重算一次占位块（内容或子视图增删后调用）
    func reload() {
        Skeleton.assertMainThread()
        base.skHost?.refresh()
    }
}

// MARK: - 列表便捷能力

public extension SkeletonWrapper where Base: UITableView {

    /// 重算所有可见 cell 上的骨架（cell 内部 if 判断即可，没有骨架的会被忽略）
    func reloadVisibleSkeletons() {
        for cell in base.visibleCells {
            cell.sk.reload()
        }
    }
}

public extension SkeletonWrapper where Base: UICollectionView {

    func reloadVisibleSkeletons() {
        for cell in base.visibleCells {
            cell.sk.reload()
        }
    }
}
