//
//  WSTodoFilterMediumListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·中·过滤器列表。逐行展示待办过滤器。
class WSTodoFilterMediumListPluginProvider: WSTodoFilterRowsPluginProvider {
    
    init() {
        super.init(type: .TodoFilter.mediumList,
                   itemCount: WSTodoFilterItemCount.mediumList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSTodoFilterContentView(itemCount: itemCount)
    }
}
