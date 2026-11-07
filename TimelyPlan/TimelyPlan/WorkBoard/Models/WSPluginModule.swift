//
//  WSPluginModule.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/16.
//

import Foundation

// MARK: - 插件模块

/// 组件模块。
///
/// 模块是组件选择器中的最小跳转单位，一个模块对应一张组件画廊。
/// 组件较多的业务可以拆成多个模块（如待办下的清单、标签、过滤器），
/// 拆分出的模块通过 `group` 归属到同一个 `WSPluginModuleGroup`。
public enum WSPluginModule: String, Codable, TPMenuRepresentable {
    case myDay      /// 我的一天
    case calendar   /// 日历
    
    case todoList   /// 待办清单
    case todoUserListTask /// 待办用户清单任务
    case todoSmartListTask /// 待办智能清单任务
    case todoTag    /// 待办标签
    case todoTagTask /// 待办标签任务
    case todoFilter /// 待办过滤器
    case todoFilterTask /// 待办过滤器任务
    case todoTask   /// 待办任务
    
    case timeline   /// 时间线
    case quadrants  /// 四象限
    case goal       /// 目标
    case focus      /// 专注
    case habit      /// 习惯
    case countdown  /// 倒数日

    /// 模块标题。同一业务拆分出的模块使用各自的名称，便于在画廊与选择器中区分。
    var title: String {
        switch self {
        case .myDay: return resGetString("My Day")
        case .calendar: return resGetString("Calendar")
        case .todoList: return resGetString("Lists")
        case .todoUserListTask: return resGetString("List Tasks")
        case .todoSmartListTask: return resGetString("Smart List Tasks")
        case .todoTag: return resGetString("Tags")
        case .todoTagTask: return resGetString("Tag Tasks")
        case .todoFilter: return resGetString("Filters")
        case .todoFilterTask: return resGetString("Filter Tasks")
        case .todoTask: return resGetString("Tasks")
        case .timeline: return resGetString("Timeline")
        case .quadrants: return resGetString("Quadrants")
        case .goal: return resGetString("Goal")
        case .focus: return resGetString("Focus")
        case .habit: return resGetString("Habit")
        case .countdown: return resGetString("Countdown")
        }
    }

    /// 模块图标。同一业务拆分出的模块暂沿用原业务图标，独立图标待设计补齐。
    var iconName: String? {
        switch self {
        case .todoList, .todoUserListTask, .todoSmartListTask, .todoTag, .todoTagTask, .todoFilter, .todoFilterTask, .todoTask:
            return "sideMenu_todo_40"
        default:
            return "sideMenu_\(rawValue)_40"
        }
    }

    /// 模块展示名称
    var displayName: String {
        return title
    }

    /// 所属模块组。选择器按组划分 section，组内按模块逐行展示。
    var group: WSPluginModuleGroup {
        switch self {
        case .todoList, .todoUserListTask, .todoSmartListTask, .todoTag, .todoTagTask, .todoFilter, .todoFilterTask, .todoTask:
            return .todo
        case .myDay, .calendar, .timeline, .quadrants, .goal, .focus, .habit, .countdown:
            return .others
        }
    }

    /// 该模块下的全部组件类型，按模块内的声明顺序排列。
    var types: [WSPluginType] {
        switch self {
        case .myDay: return WSPluginType.MyDay.all
        case .calendar: return []
        case .todoList: return WSPluginType.TodoList.all
        case .todoUserListTask: return WSPluginType.TodoUserListTask.all
        case .todoSmartListTask: return WSPluginType.TodoSmartListTask.all
        case .todoTag: return WSPluginType.TodoTag.all
        case .todoTagTask: return WSPluginType.TodoTagTask.all
        case .todoFilter: return WSPluginType.TodoFilter.all
        case .todoFilterTask: return WSPluginType.TodoFilterTask.all
        case .todoTask: return WSPluginType.TodoTask.all
        case .timeline: return WSPluginType.Timeline.all
        case .quadrants: return WSPluginType.Quadrant.all
        case .goal: return WSPluginType.Goal.all
        case .focus: return WSPluginType.Focus.all
        case .habit: return WSPluginType.Habit.all
        case .countdown: return WSPluginType.Countdown.all
        }
    }
}

// MARK: - 插件模块组

/// 组件模块组。
///
/// 一个组对应选择器中的一个 section，组内模块逐行展示。
/// 目前只把组件较多的待办单独成组，其余模块统一归入 `others`；
/// 后续需要单独成组时，新增 case 并把对应模块的 `group` 指过来即可。
public enum WSPluginModuleGroup: String, CaseIterable {
    case todo   /// 待办
    case others /// 其它

    /// 组标题
    var title: String {
        switch self {
        case .todo: return resGetString("Todo")
        case .others: return resGetString("Others")
        }
    }

    /// 组展示名称
    var displayName: String {
        return title
    }

    /// 组内全部模块，按 `WSPluginModule.allCases` 的声明顺序排列
    var modules: [WSPluginModule] {
        return WSPluginModule.allCases.filter { $0.group == self }
    }

    /// 组内可展示的模块。仅保留已实现组件的模块，未实现的模块不占用选择器条目。
    var availableModules: [WSPluginModule] {
        return modules.filter { !$0.types.isEmpty }
    }
}
