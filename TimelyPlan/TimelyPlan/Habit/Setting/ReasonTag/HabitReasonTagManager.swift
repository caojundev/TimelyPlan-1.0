//
//  HabitReasonTagManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/13.
//

import Foundation
import UIKit

/// 原因标签管理器 - 处理标签的通用业务逻辑
class HabitReasonTagManager {

    static func getReasonTags() -> [ReasonTag] {
        let reasonTags = HabitSetting.shared.reasonTags.toReasonTags()
        if reasonTags.count > 0 {
            return reasonTags
        }
        
        return ReasonTag.defaultTags()
    }

    /// 保存标签数据到设置
    /// - Parameter reasonTags: 原因标签数组
    static func saveReasonTags(_ reasonTags: [ReasonTag]) {
        HabitSetting.shared.reasonTags = reasonTags.toStrings()
    }
    
    static func editTag(type: EditType,
                        emoji: String?,
                        reason: String?,
                        completion: @escaping(String, String) -> Void) {
        let alertController = TPEmojiTitleEditAlertController()
        alertController.selectAllAtBeginning = false
        alertController.completeAfterReturn = false
        alertController.editEmoji = emoji
        alertController.editTitle = reason
        if type == .create {
            alertController.alertTitle = resGetString("New Tag")
        } else {
            alertController.alertTitle = resGetString("Edit Tag")
        }

        alertController.placeholder = resGetString("Enter Reason")
        alertController.didEndEditingEmojiTitle = { emoji, title in
            completion(String(emoji), title)
        }

        alertController.show()
    }
}
