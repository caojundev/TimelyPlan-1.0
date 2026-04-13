//
//  TodoPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/27.
//

import Foundation

class TodoPresenter {
    
    /// 显示设置
    static func showSettings() {
        let vc = TodoSettingViewController(style: .insetGrouped)
        vc.showAsNavigationRoot()
    }
    
    /// 标签编辑视图控制器
    static func showTagEditViewController(with tag: TodoEditingTag?, completion: ((TodoEditingTag) -> Bool)?){
        let vc = TodoTagEditViewController(tag: tag)
        vc.completion = completion
        vc.popoverShow()
    }
    
//    /// 显示设置视图控制器
//    static func showSettingsViewController() {
//        let vc = TodoSettingViewController(style: .insetGrouped)
//        vc.showAsNavigationRoot()
//    }
    
    
    static func showMaxTagsLimitMessage() {
        let format = resGetString("You can select up to %ld tags.")
        let message = String(format: format, kTodoTaskMaxTagsCount)
        TPFeedbackQueue.common.postFeedback(text: message, position: .middle)
    }
}
