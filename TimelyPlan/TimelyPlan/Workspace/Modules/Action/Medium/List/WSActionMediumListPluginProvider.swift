//
//  WSActionMediumListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/14.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 动作·中·列表。逐行展示用户自定义的添加与跳转动作。
class WSActionMediumListPluginProvider: WSActionPluginProvider {

    init() {
        super.init(type: .Action.mediumList,
                   itemCount: WSActionItemCount.mediumList)
    }

    override func makeContentView() -> WSPluginContentView {
        return WSActionListContentView(itemCount: itemCount)
    }
}
