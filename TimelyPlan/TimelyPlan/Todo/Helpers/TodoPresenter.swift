//
//  TodoPresenter.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/27.
//

import Foundation

class TodoPresenter {
    
    /// 显示统计
    static func showStats(date: Date = .now) {
        let vc = TodoStatsMainViewController(type: .month, date: date)
        vc.showAsNavigationRoot()
    }
    
    /// 显示搜索
    static func showSearch() {
        let vc = TodoSearchMainViewController()
        vc.showAsNavigationRoot()
    }
    
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
    
    /// 显示导入任务
    static func showTaskImporter(completion: @escaping([TodoStep]) -> Void) {
        let vc = TodoTaskImporterViewController()
        vc.completion = completion
        vc.showAsNavigationRoot()
    }
    
    /// 显示导入步骤
    static func showStepImporter(completion: @escaping([TodoStep]) -> Void) {
        let vc = TodoStepImporterViewController()
        vc.completion = completion
        vc.showAsNavigationRoot()
    }
    
    static func showMaxTagsLimitMessage() {
        let format = resGetString("You can select up to %ld tags.")
        let message = String(format: format, kTodoTaskMaxTagsCount)
        TPFeedbackQueue.common.postFeedback(text: message, position: .middle)
    }
}
