//
//  IAPStorefront.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/12.
//

import Foundation
import UIKit

// MARK: - 轻量状态订阅器

/// 管理订阅生命周期的辅助对象。
///
/// 典型用法（在 VC 里）：
/// ```swift
/// private let store = IAPStorefront(manager: .shared)
///
/// override func viewDidLoad() {
///     super.viewDidLoad()
///     store.onEntitlement = { [weak self] e in self?.updateUI(e) }
///     store.onProducts    = { [weak self] p in self?.reload(p) }
///     store.bind()   // VC 释放时 store 一并释放，订阅自动取消
/// }
/// ```

@MainActor
public final class IAPStorefront {

    public let manager: IAPManager

    /// 权益变化回调（已在主线程）
    public var onEntitlement: ((IAPEntitlement) -> Void)?
    /// 商品列表变化回调（已在主线程）
    public var onProducts: (([IAPStoreProduct]) -> Void)?

    private var entToken: IAPObservationToken?
    private var prodToken: IAPObservationToken?

    public init(manager: IAPManager? = nil) {
        self.manager = manager ?? .shared
    }

    /// 开始订阅。建议在 `viewDidLoad` 中调用。
    ///
    /// 注意：订阅的生命周期由 `IAPStorefront` 自身持有。
    /// 在 VC 中把它存为属性（`private let store = IAPStorefront(...)`），
    /// VC 释放时 `store` 一并释放，订阅自动取消，无需手动解绑。
    public func bind() {
        unbind()
        entToken = manager.observeEntitlement { [weak self] e in
            self?.onEntitlement?(e)
        }
        prodToken = manager.observeProducts { [weak self] p in
            self?.onProducts?(p)
        }
    }

    /// 主动退订
    public func unbind() {
        entToken?.cancel(); entToken = nil
        prodToken?.cancel(); prodToken = nil
    }
}
