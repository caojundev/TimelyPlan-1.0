//
//  WSTodoListLargeGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·大·清单网格。以两列网格展示待办清单。
class WSTodoListLargeGridPluginProvider: WSTodoListRowsPluginProvider {
    
    init() {
        super.init(type: .todoLargeGrid,
                   itemCount: WSTodoListItemCount.largeGrid)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSTodoListGridContentView(itemCount: itemCount,
                                         columnCount: WSTodoListItemCount.gridColumnCount)
    }
}
