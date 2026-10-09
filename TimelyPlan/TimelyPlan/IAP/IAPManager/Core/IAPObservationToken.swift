import Foundation

/// 观察者句柄。持有期间订阅有效，`deinit` 时自动取消订阅。
///
/// ```swift
/// private var token: IAPObservationToken?
/// token = iap.observeEntitlement { ... }   // 赋值保存，VC 释放时自动退订
/// ```
public final class IAPObservationToken {

    private var onCancel: (() -> Void)?

    init(onCancel: @escaping () -> Void) {
        self.onCancel = onCancel
    }

    /// 手动取消订阅（一般不需要，交给 deinit 即可）
    public func cancel() {
        onCancel?()
        onCancel = nil
    }

    deinit { onCancel?() }
}

/// 内部：把闭包包成类实例，便于用 `===` 做身份比对与移除。
final class IAPObserverBox<T> {
    let handler: (T) -> Void
    init(_ handler: @escaping (T) -> Void) { self.handler = handler }
}
