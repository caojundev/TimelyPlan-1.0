//
//  WSTodoListSmallListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/3.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·小·清单列表。逐行展示待办清单。
class WSTodoListSmallListPluginProvider: WSTodoListRowsPluginProvider {
    
    init() {
        super.init(type: .todoSmallList,
                   itemCount: WSTodoListItemCount.smallList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSTodoListListContentView(itemCount: itemCount)
    }
}
