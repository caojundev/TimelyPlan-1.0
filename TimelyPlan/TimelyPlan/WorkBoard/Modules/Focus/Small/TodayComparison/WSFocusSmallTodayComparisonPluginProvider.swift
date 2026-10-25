//
//  WSFocusSmallTodayComparisonPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 专注·小·今日对比。展示今日专注时长、与昨日的增减以及昨日时长。
class WSFocusSmallTodayComparisonPluginProvider: WSPluginProvider {
    
    var type: WSPluginType {
        return .focusSmallTodayComparison
    }
    
    func makeContentView() -> WSPluginContentView {
        return WSFocusSmallTodayComparisonContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSFocusTodayComparisonContentInteractor(plugin: plugin, context: context)
    }
}
