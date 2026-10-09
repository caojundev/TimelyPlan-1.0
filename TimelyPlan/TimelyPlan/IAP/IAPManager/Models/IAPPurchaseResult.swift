import Foundation

/// 购买流程的结果。用枚举而非 throw，方便 UI 直接分支处理。
public enum IAPPurchaseResult {
    /// 购买成功，附带刷新后的权益
    case success(entitlement: IAPEntitlement)
    /// 用户主动取消
    case userCancelled
    /// 交易待处理（如家长审批、银行验证）
    case pending
    /// 尚未验证/验证失败，附带原因
    case unverified(String)
    /// 其他失败（以文案承载错误，避免 `Error` 的 Sendable 约束）
    case failed(String)

    /// 是否成功
    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    /// 便于 UI 统一展示的错误文案
    public var message: String {
        switch self {
        case .success:            return "购买成功"
        case .userCancelled:      return "已取消"
        case .pending:            return "交易待处理，完成后将自动解锁"
        case .unverified(let r):  return "交易校验失败：\(r)"
        case .failed(let text):   return text
        }
    }
}

/// 模块对外抛出的错误类型
public enum IAPError: LocalizedError {
    case productNotFound(String)
    case noProductsLoaded
    case verificationFailed
    case unknown

    public var errorDescription: String? {
        switch self {
        case .productNotFound(let id): return "未找到商品：\(id)。请检查 Product ID 与 App Store Connect 配置。"
        case .noProductsLoaded:        return "商品尚未加载完成，请稍后重试。"
        case .verificationFailed:      return "交易签名校验未通过。"
        case .unknown:                 return "未知错误。"
        }
    }
}
