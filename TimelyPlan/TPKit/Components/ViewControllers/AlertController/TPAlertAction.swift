//
//  TPAlertAction.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/27.
//

import Foundation

class TPAlertAction: TPButtonAction {
    
    /// 是否在视图控制器dismiss前调用处理回调
    var handleBeforeDismiss: Bool = true

    init(type: TPButtonActionType = .normal,
         title: String? = nil,
         handleBeforeDismiss: Bool = true,
         handler: ((TPButtonAction) -> Void)? = nil) {
        super.init(type: type, title: title, handler: handler)
        self.handleBeforeDismiss = handleBeforeDismiss
    }
    
    static var cancel: TPAlertAction {
        return TPAlertAction(type: .cancel, title: resGetString("Cancel"))
    }
}
