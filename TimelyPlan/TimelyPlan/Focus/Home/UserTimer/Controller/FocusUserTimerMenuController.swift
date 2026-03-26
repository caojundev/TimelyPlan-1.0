//
//  FocusUserTimerMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/28.
//

import Foundation

/// 专注计时器操作菜单
enum FocusUserTimerMenuType: String, TPMenuRepresentable {
    case statistics  /// 统计
    case viewRecord /// 查看记录
    case addRecord  /// 添加记录
    case moveToTop  /// 移到顶部
    case moveToBottom /// 移到底部
    case edit       /// 编辑
    case archive    /// 归档
    case unarchive  /// 取消归档
    case delete     /// 删除
    
    var title: String {
        switch self {
        case .viewRecord:
            return resGetString("View Record")
        case .addRecord:
            return resGetString("Add Record")
        case .moveToTop:
            return resGetString("Move To Top")
        case .moveToBottom:
            return resGetString("Move To Bottom")
        default:
            return resGetString(rawValue.capitalized)
        }
    }
    
    var iconName: String? {
        switch self {
        case .addRecord:
            return "plus_24"
        case .viewRecord:
            return "focus_record_view_24"
        case .statistics:
            return "chart_bar_24"
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

class FocusUserTimerMenuController: TPBaseMenuController<FocusUserTimerMenuType> {
    
    /// 菜单作用的列表
    let timer: FocusTimer

    /// 是否显示移动到顶部
    var showMoveToTop: Bool = false
    
    /// 是否显示移动到底部
    var showMoveToBottom: Bool = false
    
    init(timer: FocusTimer) {
        self.timer = timer
        super.init()
    }
    
    override func orderedMenuActionTypeLists() -> [Array<FocusUserTimerMenuType>] {
        var lists: [Array<FocusUserTimerMenuType>]
        lists = [[.statistics],
                 [.viewRecord,
                  .addRecord],
                 [.moveToTop,
                  .moveToBottom],
                 [.edit, .archive, .unarchive, .delete]]
        return lists
    }
    
    override func menuActionTypes() -> [FocusUserTimerMenuType] {
        var types: [FocusUserTimerMenuType] = [.statistics, .delete]
        if timer.isArchived {
            /// 取消归档
            types.append(.unarchive)
        } else {
            types.append(.viewRecord)
            types.append(.addRecord)
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

