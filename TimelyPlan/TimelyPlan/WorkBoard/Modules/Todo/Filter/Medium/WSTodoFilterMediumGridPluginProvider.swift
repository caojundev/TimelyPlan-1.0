//
//  WSTodoFilterMediumGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·中·过滤器网格。以两列网格展示待办过滤器。
class WSTodoFilterMediumGridPluginProvider: WSTodoFilterRowsPluginProvider {
    
    init() {
        super.init(type: .todoFilterMediumGrid,
                   itemCount: WSTodoFilterItemCount.mediumGrid)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSTodoFilterContentView(itemCount: itemCount,
                                       layout: .grid(columnCount: WSTodoFilterItemCount.gridColumnCount))
    }
}
