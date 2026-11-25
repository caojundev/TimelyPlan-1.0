//
//  WSActionSmallListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/13.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 动作·小·列表。逐行展示用户自定义的添加与跳转动作。
class WSActionSmallListPluginProvider: WSActionPluginProvider {

    init() {
        super.init(type: .Action.smallList,
                   itemCount: WSActionItemCount.smallList)
    }

    override func makeContentView() -> WSPluginContentView {
        return WSActionListContentView(itemCount: itemCount)
    }
}
