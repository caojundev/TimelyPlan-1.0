//
//  WSTodoListMediumListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/3.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·中·清单列表。逐行展示待办清单。
class WSTodoListMediumListPluginProvider: WSTodoListRowsPluginProvider {
    
    init() {
        super.init(type: .todoMediumList,
                   itemCount: WSTodoListItemCount.mediumList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSTodoListContentView(itemCount: itemCount)
    }
}
