import Foundation
import StoreKit

/// `Transaction.updates` 长驻监听器。
/// 覆盖场景：跨设备购买、订阅自动续费、退款、家庭共享变更等。
final class TransactionObserver: @unchecked Sendable {

    private var task: Task<Void, Never>?
    private let lock = NSLock()

    /// 每收到一笔更新交易，回调一次（该交易本身 + 一笔"是否需要刷新权益"的信号）
    private let onTransaction: @Sendable (Transaction) -> Void
    /// 未验签交易回调（开发期排查用）
    private let onUnverified: @Sendable (String) -> Void

    init(
        onTransaction: @escaping @Sendable (Transaction) -> Void,
        onUnverified: @escaping @Sendable (String) -> Void
    ) {
        self.onTransaction = onTransaction
        self.onUnverified = onUnverified
    }

    func start() {
        lock.lock(); defer { lock.unlock() }
        guard task == nil else { return }

        task = Task.detached(priority: .background) { [onTransaction, onUnverified] in
            for await result in Transaction.updates {
                guard !Task.isCancelled else { break }
                switch result {
                case .verified(let transaction):
                    // 必须 finish，否则同一笔交易会反复投递
                    await transaction.finish()
                    onTransaction(transaction)

                case .unverified(_, let error):
                    onUnverified(error.localizedDescription)
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
