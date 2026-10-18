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
