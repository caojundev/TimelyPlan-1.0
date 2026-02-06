//
//  TPMenuItem.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/17.
//

import Foundation

class TPMenuItem: NSObject {
    
    /// 分区唯一标识
    var identifier: String = UUID().uuidString

    ///标题
    var title: String?

    /// 菜单动作对象数组
    var actions: [TPMenuAction]?
}

extension TPMenuItem {
    
    // MARK: - ListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}
