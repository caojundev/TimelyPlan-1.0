//
//  AppValueTransformers.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/26.
//

import Foundation

/// 任务提醒
class TaskReminderTransformer: JSONValueTransformer<TaskReminder> {}

/// 重复规则
class RepeatRuleTransformer: JSONValueTransformer<RepeatRule> {}

/// 待办过滤规则
class TodoFilterRuleTransformer: JSONValueTransformer<TodoFilterRule> {}

/// 专注计时器
class FocusTimerConfigTransformer: JSONValueTransformer<FocusTimerConfig> {}

/// 所有内容转换器
let valueTransformers = [RepeatRuleTransformer.self,
                         TaskReminderTransformer.self,
                         TodoFilterRuleTransformer.self,
                         FocusTimerConfigTransformer.self]

/// 注册转换器
func registerValueTransformers() {
    for transformer in valueTransformers {
        transformer.register()
    }
}
