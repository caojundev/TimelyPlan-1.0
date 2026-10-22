//
//  WSPlugin.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/17.
//

import Foundation

class WSPlugin: NSObject, Sortable {
    
    /// 排序因子
    var order: Int64 = 0
    
    /// 唯一标识
    let identifier: String
    
    /// 插件类型
    let type: WSPluginType
    
    /// 插件配置 JSON 字符串
    var configJSON: String?
    
    /// 创建日期
    var creationDate: Date?
    
    /// 修改日期
    var modificationDate: Date?

    init(identifier: String, type: WSPluginType) {
        self.identifier = identifier
        self.type = type
        super.init()
    }
    
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        /// 同一实例直接判定相等，省去逐属性比较
        if self === object {
            return true
        }
        
        guard let plugin = object as? WSPlugin else {
            return false
        }
        
        /// 标识不同，一定不是同一个插件
        guard identifier == plugin.identifier else {
            return false
        }
        
        /// 标识相同则继续比较其余属性，类型或配置变化都需要刷新对应内容
        return type == plugin.type
            && configJSON == plugin.configJSON
            && order == plugin.order
            && creationDate == plugin.creationDate
            && modificationDate == plugin.modificationDate
    }
}

// MARK: - 类型化配置

extension WSPlugin {
    
    /// 把插件配置解码为具体的配置模型
    func configuration<T: Decodable>(as type: T.Type) -> T? {
        guard let configJSON = configJSON else {
            return nil
        }
        
        return T.model(with: configJSON)
    }
    
    /// 用配置模型更新配置 JSON，保留更高版本写入的字段
    func configurationJSON<T: Encodable>(updatingWith configuration: T) -> String? {
        return WSPluginConfigJSONMerger.merging(base: configJSON, model: configuration)
    }
}
