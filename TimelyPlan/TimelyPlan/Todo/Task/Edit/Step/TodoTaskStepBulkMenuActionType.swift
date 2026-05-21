//
//  TodoTaskStepBulkMenuActionType.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/21.
//

import Foundation

enum TodoTaskStepBulkMenuActionType: String, TPMenuRepresentable {
    case importSteps      /// 批量导入步骤
    case copyStepsAsMarkdown /// 拷贝所有步骤 markdown 文本
    case deleteCompletedSteps /// 删除已完成步骤
    
    var title: String {
        switch self {
        case .importSteps:
            return resGetString("Import Steps")
        case .copyStepsAsMarkdown:
            return resGetString("Copy Steps As Markdown")
        case .deleteCompletedSteps:
            return resGetString("Delete Completed Steps")
        }
    }
    
    var actionStyle: TPMenuActionStyle {
        if self == .deleteCompletedSteps {
            return .destructive
        }
        
        return .normal
    }
}
