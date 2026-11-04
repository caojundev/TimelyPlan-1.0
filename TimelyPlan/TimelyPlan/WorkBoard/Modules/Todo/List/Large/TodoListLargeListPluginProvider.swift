//
//  TodoListLargeListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/3.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·大·清单列表。逐行展示待办清单。
class TodoListLargeListPluginProvider: TodoListRowsPluginProvider {
    
    init() {
        super.init(type: .todoLargeList,
                   itemCount: TodoListItemCount.largeList)
    }
    
    override func makeContentView() -> WSPluginContentView {
        return TodoListListContentView(itemCount: itemCount)
    }
}
