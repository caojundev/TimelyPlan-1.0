//
//  WSTodoListMediumGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·中·清单网格。以两列网格展示待办清单。
class WSTodoListMediumGridPluginProvider: WSTodoListRowsPluginProvider {
    
    init() {
        super.init(type: .TodoList.mediumGrid,
                   itemCount: WSTodoListItemCount.mediumGrid)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSTodoListContentView(itemCount: itemCount,
                                     layout: .grid(columnCount: WSTodoListItemCount.gridColumnCount))
    }
}
