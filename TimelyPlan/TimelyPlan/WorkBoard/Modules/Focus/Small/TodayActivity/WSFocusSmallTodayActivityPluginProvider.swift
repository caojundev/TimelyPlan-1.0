//
//  WSFocusSmallTodayActivityPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 专注·小·今日活动。展示今日专注总时长与每小时活动分布。
class WSFocusSmallTodayActivityPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .focusSmallTodayActivity
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSFocusSmallTodayActivityContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSFocusTodayActivityContentInteractor(plugin: plugin, context: context)
    }
}
