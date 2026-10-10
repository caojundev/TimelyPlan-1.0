//
//  IAPTransactionObserver.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/05.
//

import Foundation
import StoreKit

/// `Transaction.updates` 长驻监听器。
///
/// 用法：先 `configure(onTransaction:onUnverified:)` 配置回调，再 `start()`。
/// 回调会在 `start()` 时被拷贝进后台任务，因此配置必须在 `start()` 之前完成。
final class IAPTransactionObserver: @unchecked Sendable {

    private var task: Task<Void, Never>?
    private let lock = NSLock()

    /// 每收到一笔更新交易，回调一次（交易已 `finish`）
    private(set) var onTransaction: (@Sendable (Transaction) -> Void)?
    /// 未验签交易回调（开发期排查用）
    private(set) var onUnverified: (@Sendable (String) -> Void)?

    /// 配置回调。必须在 `start()` 之前调用。
    ///
    /// 之所以不在 `init` 里接线：这些回调是逃逸闭包，若在 `IAPManager.init` 阶段
    /// 创建并捕获 `self`，会触发 “self used before being initialized”。
    /// 放到 `start()` 中配置，闭包创建时 `self` 早已初始化完成。
    func configure(
        onTransaction: @escaping @Sendable (Transaction) -> Void,
        onUnverified: @escaping @Sendable (String) -> Void
    ) {
        lock.lock(); defer { lock.unlock() }
        self.onTransaction = onTransaction
        self.onUnverified = onUnverified
    }

    func start() {
        lock.lock(); defer { lock.unlock() }
        guard task == nil else { return }

        let onTransaction = self.onTransaction
        let onUnverified = self.onUnverified

        task = Task.detached(priority: .background) { [onTransaction, onUnverified] in
            for await result in Transaction.updates {
                guard !Task.isCancelled else { break }
                switch result {
                case .verified(let transaction):
                    // 必须 finish，否则同一笔交易会反复投递
                    await transaction.finish()
                    onTransaction?(transaction)

                case .unverified(_, let error):
                    onUnverified?(error.localizedDescription)
                }
            }
        }
    }

    func stop() {
        lock.lock(); defer { lock.unlock() }
        task?.cancel()
        task = nil
    }
}
