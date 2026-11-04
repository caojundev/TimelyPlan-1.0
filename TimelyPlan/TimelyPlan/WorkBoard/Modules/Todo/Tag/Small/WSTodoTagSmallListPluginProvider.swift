//
//  WSTodoTagSmallListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·小·标签列表。逐行展示待办标签。
class WSTodoTagSmallListPluginProvider: WSTodoTagRowsPluginProvider {
    
    init() {
        super.init(type: .todoTagSmallList,
                   itemCount: WSTodoTagItemCount.smallList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSTodoTagContentView(itemCount: itemCount)
    }
}
