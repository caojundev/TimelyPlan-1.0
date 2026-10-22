// 文件：Workspace/Sources/Workspace/Core/Models/WSPluginSize.swift

import Foundation

public enum WSPluginSize: String, Codable, CaseIterable {
    case small   // 1x1
    case medium  // 2x1
    case large   // 2x2
}

public extension WSPluginSize {

    /// 尺寸对应的用户可见名称。
    var displayName: String {
        switch self {
        case .small: return "小"
        case .medium: return "中"
        case .large: return "大"
        }
    }

    /// 排序权重，由小到大。用于组件选择器内的稳定排序。
    var order: Int {
        switch self {
        case .small: return 0
        case .medium: return 1
        case .large: return 2
        }
    }
}
