//
//  WSActionMediumGridPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/14.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 动作·中·网格。以两列网格展示用户自定义的添加与跳转动作。
class WSActionMediumGridPluginProvider: WSActionPluginProvider {

    init() {
        super.init(type: .Action.mediumGrid,
                   itemCount: WSActionItemCount.mediumGrid)
    }

    override func makeContentView() -> WSPluginContentView {
        return WSActionGridContentView(itemCount: itemCount,
                                       columnCount: WSActionItemCount.gridColumnCount)
    }
}
