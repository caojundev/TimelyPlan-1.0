//
//  TodoListSmallListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/3.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·小·清单列表。逐行展示待办清单。
class TodoListSmallListPluginProvider: TodoListRowsPluginProvider {
    
    init() {
        super.init(type: .todoSmallList,
                   itemCount: TodoListItemCount.smallList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return TodoListListContentView(itemCount: itemCount)
    }
}
