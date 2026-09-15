//
//  CountdownMoreBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/15.
//

import Foundation
import UIKit

/// 更多菜单
enum CountdownMoreMenuType: Int, TPMenuRepresentable {
    case archived /// 已归档
    
    static func titles() -> [String] {
        return ["Archived"]
    }
    
    var iconName: String? {
        switch self {
        case .archived:
            return "archivedList_24"
        }
    }
}

class CountdownMoreBarButtonItem: TPBaseMoreMenuBarButtonItem<CountdownMoreMenuType> {
    
    override func menuItems() -> [TPMenuItem] {
        let archivedCount = CountdownRepository.numberOfArchivedEvents()
        let typeLists: [Array<CountdownMoreMenuType>] = [[.archived]]
        let items = TPMenuItem.items(with: typeLists) { type, action in
            if type == .archived {
                action.valueText = "\(archivedCount)"
            }
        }
        
        return items
    }
    
    override func selectMenuAction(_ action: TPMenuAction) {
        if let type = CountdownMoreMenuType(rawValue: action.tag) {
            didSelectType?(type)
        }
    }
}
