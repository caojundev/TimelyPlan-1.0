//
//  WSPluginConfigJSONMerger.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation

/// 组件配置模型可选的键声明。
///
/// 默认情况下，合并工具通过反射属性名得到模型认识的 JSON 键。
/// 模型若使用 `CodingKeys` 重命名属性，或存在不参与编码的存储属性，
/// 可实现该协议显式声明，避免未知字段被误判为已知字段而移除。
protocol WSPluginConfigKeyProviding {
    
    /// 模型认识的全部 JSON 键
    var knownConfigJSONKeys: Set<String> { get }
}

extension WSPluginConfigKeyProviding {
    
    /// 默认实现：反射存储属性名
    var knownConfigJSONKeys: Set<String> {
        return Set(Mirror(reflecting: self).children.compactMap { $0.label })
    }
}

/// 组件配置 JSON 的合并工具。
///
/// 组件配置会随版本演进增加字段。低版本读取高版本保存的配置时，
/// 若把解码后的模型整体重新编码写回，不认识的字段会丢失。
/// 合并工具以原始配置为基准，仅覆盖当前版本模型认识的字段，
/// 其余字段原样保留，保证不同版本之间的配置互不破坏。
enum WSPluginConfigJSONMerger {
    
    /// 用当前版本的配置模型更新原始配置
    /// - Parameters:
    ///   - base: 原始配置 JSON 字符串，可能包含当前版本不认识的字段
    ///   - model: 当前版本的配置模型
    /// - Returns: 合并后的配置 JSON 字符串。模型编码失败时返回原始配置，避免破坏数据
    static func merging<Content: Encodable>(base: String?, model: Content) -> String? {
        guard let data = model.jsonData() else {
            return base
        }
        
        /// 顶层不是 JSON 对象时无法按字段合并，保持整体替换
        guard let changes = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
            return String(data: data, encoding: .utf8)
        }
        
        /// 原始配置缺失或不可解析时，直接使用模型编码结果
        guard let base = base,
              let baseObject = base.jsonObject() else {
            return changes.jsonString()
        }
        
        let merged = merge(base: baseObject,
                           changes: changes,
                           knownKeys: knownJSONKeys(of: model))
        return merged.jsonString()
    }
}

private extension WSPluginConfigJSONMerger {
    
    /// 递归合并配置对象。
    ///
    /// 模型认识但没有输出的键（`Optional` 为 `nil`）视为显式清空，从原始配置中移除；
    /// 模型不认识的键原样保留；子结构同为对象时递归合并，保留其中的未知字段
    static func merge(base: [String: Any],
                      changes: [String: Any],
                      knownKeys: Set<String>) -> [String: Any] {
        var result = base
        
        for key in knownKeys where changes[key] == nil {
            result.removeValue(forKey: key)
        }
        
        for (key, value) in changes {
            if let baseValue = result[key] as? [String: Any],
               let changesValue = value as? [String: Any] {
                result[key] = merge(base: baseValue,
                                    changes: changesValue,
                                    knownKeys: Set(changesValue.keys))
            } else {
                result[key] = value
            }
        }
        
        return result
    }
    
    /// 模型认识的全部 JSON 键，用于识别被显式清空的字段
    static func knownJSONKeys<Content: Encodable>(of model: Content) -> Set<String> {
        if let provider = model as? WSPluginConfigKeyProviding {
            return provider.knownConfigJSONKeys
        }
        
        return Set(Mirror(reflecting: model).children.compactMap { $0.label })
    }
}

private extension String {
    
    /// 解析为 JSON 对象
    func jsonObject() -> [String: Any]? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}

private extension Dictionary where Key == String, Value == Any {
    
    /// 输出为 JSON 字符串。使用排序键保证相同内容输出稳定
    func jsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: [.sortedKeys]) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
}
