//
//  WSTodoTagMediumListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·中·标签列表。逐行展示待办标签。
class WSTodoTagMediumListPluginProvider: WSTodoTagRowsPluginProvider {
    
    init() {
        super.init(type: .TodoTag.mediumList,
                   itemCount: WSTodoTagItemCount.mediumList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return WSTodoTagContentView(itemCount: itemCount)
    }
}
