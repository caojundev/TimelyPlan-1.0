//
//  WSCountdownMediumRecentPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/21.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 倒数日·中·最近。展示距离当前日期最近的三个倒数日事项。
class WSCountdownMediumRecentPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .countdownMediumRecent
    }
    
    /// 该组件尺寸
    var size: WSPluginSize {
        return .medium
    }
    
    /// 该组件注册的单元格类
    var cellClass: WSPluginCell.Type {
        return WSCountdownMediumRecentPluginCell.self
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCountdownRecentContentInteractor(plugin: plugin,
                                                  context: context,
                                                  maximumItemCount: WSCountdownRecentItemCount.medium)
    }
}
