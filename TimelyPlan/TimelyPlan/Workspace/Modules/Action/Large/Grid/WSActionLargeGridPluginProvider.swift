//
//  WSActionLargeGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/14.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 动作·大·网格。以两列四行的卡片展示用户自定义的添加与跳转动作。
class WSActionLargeGridPluginProvider: WSActionPluginProvider {

    init() {
        super.init(type: .Action.largeGrid,
                   itemCount: WSActionItemCount.largeGrid)
    }

    override func makeContentView() -> WSPluginContentView {
        return WSActionGridContentView(itemCount: itemCount,
                                       columnCount: WSActionItemCount.gridColumnCount)
    }
}
