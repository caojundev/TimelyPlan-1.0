//
//  WSTodoTagLargeGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·大·标签网格。以两列网格展示待办标签。
class WSTodoTagLargeGridPluginProvider: WSTodoTagRowsPluginProvider {
    
    init() {
        super.init(type: .todoTagLargeGrid,
                   itemCount: WSTodoTagItemCount.largeGrid)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSTodoTagContentView(itemCount: itemCount,
                                    layout: .grid(columnCount: WSTodoTagItemCount.gridColumnCount))
    }
}
