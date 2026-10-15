//
//  WSPluginElement.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation

class WSPluginElement: NSObject {
    
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
        if let object = object as? WSPluginElement {
            return self.identifier == object.identifier
        }
        
        return false
    }
}

// MARK: - Mock
extension WSPluginElement {
    
    /// 生成测试数据。小 / 中 / 大三种尺寸循环出现，便于验证网格布局。
    static func mockElements(count: Int = 10) -> [WSPluginElement] {
        return [WSPluginElement(type: .countdownSmall),
                WSPluginElement(type: .countdownSmall),
                WSPluginElement(type: .countdownMedium),
                WSPluginElement(type: .countdownLarge),
                WSPluginElement(type: .countdownMedium),
                WSPluginElement(type: .countdownSmall),
                WSPluginElement(type: .countdownSmall),
                WSPluginElement(type: .countdownSmall),
                WSPluginElement(type: .countdownSmall),
                WSPluginElement(type: .countdownSmall),
                WSPluginElement(type: .countdownSmall),
                WSPluginElement(type: .countdownSmall),
                WSPluginElement(type: .countdownSmall),
                WSPluginElement(type: .countdownMedium)
        ]

    }
}
