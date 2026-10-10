//
//  IAPConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/05.
//

import Foundation

/// 模块的全部可调参数。**接入时通常只需要填 `products`。**
public struct IAPConfiguration: Sendable {

    /// 商品清单——唯一的必填项
    public var products: [IAPProduct]

    /// 是否在网络可用时才允许购买（默认 false）
    public var requiresNetwork: Bool

    /// 是否在启动时自动开始监听 `Transaction.updates`（默认 true）
    public var autoStartObserving: Bool

    public init(
        products: [IAPProduct],
        requiresNetwork: Bool = false,
        autoStartObserving: Bool = true
    ) {
        self.products = products
        self.requiresNetwork = requiresNetwork
        self.autoStartObserving = autoStartObserving
    }

    // MARK: - 派生索引

    /// id -> IAPProduct
    var productIndex: [String: IAPProduct] {
        Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })
    }

    /// id -> group，供 `IAPEntitlement.hasAccess(toGroup:)` 使用
    var groupIndex: [String: String] {
        Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0.group) })
    }
}
