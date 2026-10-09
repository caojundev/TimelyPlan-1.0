import Foundation

/// 商品类型。决定了权益的有效性判定方式。
public enum ProductKind: String, Codable, Sendable {
    /// 自动续订订阅（月 / 年）
    case subscription
    /// 买断制（永久有效）
    case nonConsumable
}

/// 一个可售商品的静态描述。
/// 你只需要在这里填 `id`，其余字段用于业务侧辨别与展示分组。
public struct IAPProduct: Sendable, Hashable, Identifiable {

    /// ⚠️ 与 App Store Connect 中填写的 Product ID 完全一致（区分大小写）
    public let id: String

    /// 商品类型
    public let kind: ProductKind

    /// 业务分组：同组订阅（如 "premium"）互斥，买断制通常单独成组。
    /// 默认取 `id`，一般无需关心。
    public let group: String

    /// 展示顺序（小的在前）
    public let order: Int

    public init(
        id: String,
        kind: ProductKind,
        group: String? = nil,
        order: Int = 0
    ) {
        self.id = id
        self.kind = kind
        self.group = group ?? id
        self.order = order
    }
}

// MARK: - 便捷构造

public extension IAPProduct {
    /// 月订阅
    static func monthly(_ id: String, group: String = "default", order: Int = 0) -> IAPProduct {
        .init(id: id, kind: .subscription, group: group, order: order)
    }

    /// 年订阅
    static func yearly(_ id: String, group: String = "default", order: Int = 1) -> IAPProduct {
        .init(id: id, kind: .subscription, group: group, order: order)
    }

    /// 永久买断
    static func lifetime(_ id: String, order: Int = 0) -> IAPProduct {
        .init(id: id, kind: .nonConsumable, group: "lifetime", order: order)
    }
}
