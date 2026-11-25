
import Foundation
import UIKit

public final class WSPluginRegistry {

    public static let shared = WSPluginRegistry()

    private var providers: [WSPluginType: WSPluginProvider] = [:]
    private let lock = NSLock()

    private init() {}

    // MARK: - 注册

    /// 注册一个组件提供者
    func register(_ provider: WSPluginProvider) {
        store(provider)
    }

    /// 移除指定类型的注册，返回被移除的提供者。用于测试中隔离注册状态。
    @discardableResult
    func unregister(_ type: WSPluginType) -> WSPluginProvider? {
        lock.lock()
        defer { lock.unlock() }
        return providers.removeValue(forKey: type)
    }

    private func store(_ box: WSPluginProvider) {
        lock.lock()
        defer { lock.unlock() }
        providers[box.type] = box
    }

    // MARK: - 查询

    /// 按类型取回提供者。
    func provider(for type: WSPluginType) -> WSPluginProvider? {
        lock.lock()
        defer { lock.unlock() }
        return providers[type]
    }

    /// 全部已注册的提供者，按 `WSPluginType` 中的声明顺序排列。
    var allProviders: [WSPluginProvider] {
        lock.lock()
        defer { lock.unlock() }
        return providers.values.sorted { lhs, rhs in
            let lhsIndex = Self.typeOrder[lhs.type] ?? 0
            let rhsIndex = Self.typeOrder[rhs.type] ?? 0
            return lhsIndex < rhsIndex
        }
    }

    /// 组件类型的声明顺序，用于稳定排序
    private static let typeOrder: [WSPluginType: Int] = {
        var result = [WSPluginType: Int]()
        for (index, type) in WSPluginType.allCases.enumerated() {
            result[type] = index
        }
        return result
    }()

    /// 按模块分组后的提供者，供组件选择器分 section 展示。
    /// 仅返回已注册组件的模块。
    var providersGroupedByModule: [(module: WSPluginModule, providers: [WSPluginProvider])] {
        let grouped = Dictionary(grouping: allProviders) { $0.type.module }
        return WSPluginModule.allCases.compactMap { module in
            guard let items = grouped[module], !items.isEmpty else { return nil }
            return (module, items)
        }
    }

    /// 当前已注册的组件类型集合。
    var registeredTypes: Set<WSPluginType> {
        lock.lock()
        defer { lock.unlock() }
        return Set(providers.keys)
    }
}
