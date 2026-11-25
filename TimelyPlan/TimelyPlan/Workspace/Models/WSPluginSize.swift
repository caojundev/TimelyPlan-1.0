// 文件：Workspace/Sources/Workspace/Core/Models/WSPluginSize.swift

import Foundation

public enum WSPluginSize: String, Codable, CaseIterable {
    case small   // 1x1
    case medium  // 2x1
    case large   // 2x2
    case flexible // 整行宽，高度按宽度动态计算
}

public extension WSPluginSize {

    /// 尺寸对应的用户可见名称。
    var displayName: String {
        switch self {
        case .small: return resGetString("Small")
        case .medium: return resGetString("Medium")
        case .large: return resGetString("Large")
        case .flexible: return resGetString("Flexible")
        }
    }
}
