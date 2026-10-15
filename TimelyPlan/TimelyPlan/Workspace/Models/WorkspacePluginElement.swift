//
//  WorkspacePluginElement.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation

class WorkspacePluginElement: NSObject {
    
    let identifier = UUID().uuidString
    
    let type: WSPluginType
    
    init(type: WSPluginType) {
        self.type = type
        super.init()
    }
    
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? WorkspacePluginElement {
            return self.identifier == object.identifier
        }
        
        return false
    }
}

// MARK: - Mock
extension WorkspacePluginElement {
    
    /// 生成测试数据。小 / 中 / 大三种尺寸循环出现，便于验证网格布局。
    static func mockElements(count: Int = 10) -> [WorkspacePluginElement] {
        return [WorkspacePluginElement(type: .countdownSmall),
                WorkspacePluginElement(type: .countdownSmall),
                WorkspacePluginElement(type: .countdownMedium),
                WorkspacePluginElement(type: .countdownLarge),
                WorkspacePluginElement(type: .countdownMedium),
                WorkspacePluginElement(type: .countdownSmall),
                WorkspacePluginElement(type: .countdownSmall),
                WorkspacePluginElement(type: .countdownSmall),
                WorkspacePluginElement(type: .countdownSmall),
                WorkspacePluginElement(type: .countdownSmall),
                WorkspacePluginElement(type: .countdownSmall),
                WorkspacePluginElement(type: .countdownSmall),
                WorkspacePluginElement(type: .countdownSmall),
                WorkspacePluginElement(type: .countdownMedium)
        ]

    }
}
