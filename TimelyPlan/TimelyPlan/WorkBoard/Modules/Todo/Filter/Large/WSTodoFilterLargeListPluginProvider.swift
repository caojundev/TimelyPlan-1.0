//
//  WSTodoFilterLargeListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·大·过滤器列表。逐行展示待办过滤器。
class WSTodoFilterLargeListPluginProvider: WSTodoFilterRowsPluginProvider {
    
    init() {
        super.init(type: .todoFilterLargeList,
                   itemCount: WSTodoFilterItemCount.largeList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSTodoFilterContentView(itemCount: itemCount)
    }
}
