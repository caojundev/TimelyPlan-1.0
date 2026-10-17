//
//  WSDashboard.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/17.
//

import Foundation
import UIKit

class WSDashboard: NSObject, Sortable, TPHexColorConvertible {
    
    /// 唯一标识
    let identifier: String
    
    /// 排序因子
    var order: Int64 = 0
    
    /// 名称
    var name: String?
    
    /// 颜色十六进制字符串
    var colorHex: String?

    /// 创建日期
    var creationDate: Date?
    
    /// 修改日期
    var modificationDate: Date?
    
    init(identifier: String) {
        self.identifier = identifier
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
        
        guard let dashboard = object as? WSDashboard else {
            return false
        }
        
        /// 标识不同，一定不是同一个仪表盘
        guard identifier == dashboard.identifier else {
            return false
        }
        
        /// 标识相同则继续比较其余属性，任一属性变化都视为不相等，以便刷新对应内容
        return name == dashboard.name
            && colorHex == dashboard.colorHex
            && order == dashboard.order
            && creationDate == dashboard.creationDate
            && modificationDate == dashboard.modificationDate
    }
}
