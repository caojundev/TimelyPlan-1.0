//
//  CountdownEventMenu.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation

/// 倒数日事项操作菜单
enum CountdownEventMenuType: String, TPMenuRepresentable {
    case edit         /// 编辑
    case archive      /// 归档
    case unarchive    /// 取消归档
    case delete       /// 删除
    
    var title: String {
        switch self {
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

class CountdownEventMenuController: TPBaseMenuController<CountdownEventMenuType> {
    
    /// 菜单作用的倒数日事项
    let event: CountdownEvent
    
    init(event: CountdownEvent) {
        self.event = event
        super.init()
    }
    
    override func orderedMenuActionTypeLists() -> [Array<CountdownEventMenuType>] {
        return [[.edit, .archive, .unarchive, .delete]]
    }
    
    override func menuActionTypes() -> [CountdownEventMenuType] {
        var types: [CountdownEventMenuType] = [.delete]
        if event.isArchived {
            /// 取消归档
            types.append(.unarchive)
        } else {
            types.append(.edit)
            types.append(.archive)
        }
        
        return types
    }
}

class CountdownEventMenuProcessor {
    
    func performMenuAction(_ type: CountdownEventMenuType, for event: CountdownEvent) {
        switch type {
        case .edit:
            CountdownPresenter.editEvent(event)
        case .archive:
            CountdownRepository.archiveEvent(event)
        case .unarchive:
            CountdownRepository.unarchiveEvent(event)
        case .delete:
            deleteEvent(event)
        }
    }
    
    /// 弹窗确认删除事项
    func deleteEvent(_ event: CountdownEvent) {
        let deleteAction = TPAlertAction(type: .destructive,
                                         title: resGetString("Delete")) { action in
            CountdownRepository.deleteEvent(event)
        }
        
        let cancelAction = TPAlertAction(type: .cancel,
                                         title: resGetString("Cancel"))
        
        let format: String = resGetString("\"%@\" will be permanently deleted.")
        let message = String(format: format, event.displayName)
        let alertController = TPAlertController(title: resGetString("Delete Countdown"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }
}
