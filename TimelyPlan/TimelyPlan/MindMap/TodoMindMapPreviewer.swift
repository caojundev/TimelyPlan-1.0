//
//  TodoMindMapPreviewer.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/8.
//

import Foundation
import UIKit

/// 列表导图的数据快照
struct TodoMindMapList: TPHexColorConvertible {
    
    /// 唯一标识
    let identifier: String
    
    /// 列表名称
    let name: String
    
    /// 颜色
    var colorHex: String?
    
    /// 表情符号
    let emoji: String?
    
    /// 布局
    let layoutType: TodoListLayoutType

    /// 列表包含的任务
    let tasks: [TodoTask]?

    /// 子列表
    let sublists: [TodoMindMapList]?
    
    /// 指定图标名称；为 nil 时按 emoji / 布局类型推导（收件箱等智能清单用）。
    let iconName: String?
    
    /// 列表图标
    var icon: TPIcon? {
        if let emoji = emoji {
            return TPIcon(text: emoji)
        }
        
        if let iconName = iconName {
            return TPIcon(name: iconName)
        }
        
        return TPIcon(name: layoutType.miniIconName)
    }

}

/// 列表导图预览：从仓库取列表导图快照，转换成 `MindMapNode` 后弹出导图。
enum TodoMindMapPreviewer {
    
    /// 预览一个列表：从仓库异步取导图快照（加载期间显示加载指示器），取到后弹出导图。
    /// - Parameter list: 目标列表；nil 表示收件箱。
    static func preview(_ list: TodoList?) {
        TPLoadingIndicator.showLoading(resGetString("Loading......"))
        TodoRepository.fetchMindMapList(for: list) { mindMapList in
            TPLoadingIndicator.hideLoading()
            
            guard let mindMapList = mindMapList else {
                return
            }
            
            preview(mindMapList)
        }
    }
    
    /// 预览一个列表导图快照（含其任务与子列表）。
    static func preview(_ list: TodoMindMapList) {
        let viewController = MindMapMainViewController()
        viewController.rootNode = TodoMindMapConverter.node(from: list)
        viewController.modalPresentationStyle = .fullScreen
        viewController.show()
    }
}
