//
//  GoalPlanMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation

/// 目标计划操作菜单
enum GoalPlanMenuType: String, TPMenuRepresentable {
    case moveToTop    /// 移到顶部
    case moveToBottom /// 移到底部
    case edit         /// 编辑
    case archive      /// 归档
    case unarchive    /// 取消归档
    case delete       /// 删除
    
    var title: String {
        switch self {
        case .moveToTop:
            return resGetString("Move To Top")
        case .moveToBottom:
            return resGetString("Move To Bottom")
        case .edit:
            return resGetString("Edit")
        case .archive:
            return resGetString("Archive")
        case .unarchive:
            return resGetString("Unarchive")
        case .delete:
            return resGetString("Delete")
        }
    }
    
    var iconName: String? {
        switch self {
        case .delete:
            return "shred_24"
        default:
            return rawValue + "_24"
        }
    }
    
    var actionStyle: TPMenuActionStyle {
        if self == .delete {
            return .destructive
        }
        
        return .normal
    }
}

class GoalPlanMenuController: TPBaseMenuController<GoalPlanMenuType> {
    
    /// 菜单作用的目标计划
    let goalPlan: GoalPlan
    
    /// 是否显示移动到顶部
    var showMoveToTop: Bool = false
    
    /// 是否显示移动到底部
    var showMoveToBottom: Bool = false
    
    init(goalPlan: GoalPlan) {
        self.goalPlan = goalPlan
        super.init()
    }
    
    override func orderedMenuActionTypeLists() -> [Array<GoalPlanMenuType>] {
        return [[.moveToTop, .moveToBottom],
                [.edit, .archive, .unarchive, .delete]]
    }
    
    override func menuActionTypes() -> [GoalPlanMenuType] {
        var types: [GoalPlanMenuType] = [.delete]
        if goalPlan.isArchived {
            /// 取消归档
            types.append(.unarchive)
        } else {
            types.append(.edit)
            types.append(.archive)
            if showMoveToTop {
                types.append(.moveToTop)
            }
            
            if showMoveToBottom {
                types.append(.moveToBottom)
            }
        }
        
        return types
    }
}
