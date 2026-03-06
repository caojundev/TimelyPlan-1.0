//
//  HabitTaskMenuActionType.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/6.
//

import Foundation

enum HabitTaskMenuActionType: String, TPMenuRepresentable {
    
    case resetToday     /// 重置今日数据
    case cancelSkip     /// 取消跳过
    case completeAll /// 完成所有
    case checkin   /// 打卡
    case addRecord /// 手动记录
    case markAsFail /// 标记为失败
    case cancelFail /// 取消失败
    case skipToday /// 跳过今日
    case editLog /// 添加日志
    case edit    /// 编辑
    case archive /// 归档
    case unarchive /// 解除归档
    case delete  /// 删除
    
    var title: String {
        let title: String
        switch self {
        case .resetToday:
            title = "Reset Today"
        case .cancelSkip:
            title = "Cancel Skip"
        case .completeAll:
            title = "Complete All"
        case .checkin:
            title = "Check-in"
        case .addRecord:
            title = "Add Record"
        case .markAsFail:
            title = "Mark As Fail"
        case .cancelFail:
            title = "Cancel Fail"
        case .skipToday:
            title = "Skip Today"
        case .editLog:
            title = "Edit Log"
        case .edit:
            title = "Edit"
        case .archive:
            title = "Archive"
        case .unarchive:
            title = "Unarchive"
        case .delete:
            title = "Delete"
        }
        
        return resGetString(title)
    }
    
    var iconName: String? {
        switch self {
//        case .resetToday:
//            <#code#>
//        case .cancelSkip:
//            <#code#>
//        case .completeAll:
//            <#code#>
//        case .checkin:
//            <#code#>
//        case .addRecord:
//            <#code#>
//        case .markAsFail:
//            <#code#>
//        case .cancelFail:
//            <#code#>
//        case .skipToday:
//            <#code#>
//        case .editLog:
//            <#code#>
        case .edit:
            return "edit_24"
        case .archive:
            return "archive_24"
        case .unarchive:
            return "unarchive_24"
        case .delete:
            return "shred_24"
        default:
            return nil
        }
    }
    
    var actionStyle: TPMenuActionStyle {
        if self == .delete {
            return .destructive
        }
        
        return .normal
    }    
}
