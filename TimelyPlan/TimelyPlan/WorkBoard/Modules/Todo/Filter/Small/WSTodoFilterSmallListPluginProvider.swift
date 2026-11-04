//
//  WSTodoFilterSmallListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·小·过滤器列表。逐行展示待办过滤器。
class WSTodoFilterSmallListPluginProvider: WSTodoFilterRowsPluginProvider {
    
    init() {
        super.init(type: .todoFilterSmallList,
                   itemCount: WSTodoFilterItemCount.smallList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSTodoFilterContentView(itemCount: itemCount)
    }
}
