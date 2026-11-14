//
//  WSActionLargeListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/14.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 动作·大·列表。逐行展示用户自定义的添加与跳转动作。
class WSActionLargeListPluginProvider: WSActionPluginProvider {

    init() {
        super.init(type: .Action.largeList,
                   itemCount: WSActionItemCount.largeList)
    }

    override func makeContentView() -> WSPluginContentView {
        return WSActionListContentView(itemCount: itemCount)
    }
}
