//
//  Skeleton.swift
//  Skeleton
//
//  全局开关
//

import UIKit

public enum Skeleton {

    /// 全局默认配置，`view.sk.show()` 不传参时使用
    public static var config: SkeletonConfig = .default

    /// 便捷地修改全局配置
    /// ```
    /// Skeleton.configure {
    ///     $0.animation = .none
    ///     $0.cornerRadius = 6
    /// }
    /// ```
    public static func configure(_ block: (inout SkeletonConfig) -> Void) {
        block(&config)
    }

    @inline(__always)
    static func assertMainThread() {
        #if DEBUG
        if !Thread.isMainThread {
            assertionFailure("Skeleton 是 UI 组件，必须在主线程调用")
        }
        #endif
    }
}
