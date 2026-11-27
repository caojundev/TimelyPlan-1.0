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
/// 模块是组件选择器中的最小跳转单位：组件较多的模块对应一张组件画廊，
/// 只有单个组件的模块则由选择器直接添加，不再进入画廊。
/// 组件较多的业务可以拆成多个模块（如待办下的清单、标签、过滤器），
/// 拆分出的模块通过 `group` 归属到同一个 `WSPluginModuleGroup`。
public enum WSPluginModule: String, Codable, TPMenuRepresentable {
    case todoListGroup   /// 待办清单组
    case todoTagGroup    /// 待办标签组
    case todoFilterGroup /// 待办过滤器组
    
    case todoUserListTask /// 待办用户清单任务
    case todoSmartListTask /// 待办智能清单任务
    case todoTagTask /// 待办标签任务
    case todoFilterTask /// 待办过滤器任务
    case todoCustomTask /// 待办自定义任务
    
    case myDay      /// 我的一天
    case timeline   /// 时间线
    case quadrants  /// 四象限
    case focus      /// 专注
    
    case calendar   /// 日历
    case goal       /// 目标
    
    case habit      /// 习惯
    case countdown  /// 倒数日
    case text       /// 文本
    case separator  /// 分割线
    case action     /// 动作

    /// 模块标题。同一业务拆分出的模块使用各自的名称，便于在画廊与选择器中区分。
    var title: String {
        switch self {
        case .myDay: return resGetString("My Day")
        case .calendar: return resGetString("Calendar")
    
        case .todoListGroup: return resGetString("Lists")
        case .todoTagGroup: return resGetString("Tags")
        case .todoFilterGroup: return resGetString("Filters")
    
        case .todoUserListTask: return resGetString("User List")
        case .todoSmartListTask: return resGetString("Smart List")
        case .todoTagTask: return resGetString("Tag Tasks")
        case .todoFilterTask: return resGetString("Filter Tasks")
        case .todoCustomTask: return resGetString("Custom Tasks")
            
        case .timeline: return resGetString("Timeline")
        case .quadrants: return resGetString("Quadrants")
        case .goal: return resGetString("Goal")
        case .focus: return resGetString("Focus")
        case .habit: return resGetString("Habit")
        case .countdown: return resGetString("Countdown")
        case .text: return resGetString("Text")
        case .separator: return resGetString("Separator")
        case .action: return resGetString("Action")
        }
    }

    /// 模块图标。同一业务拆分出的模块暂沿用原业务图标，独立图标待设计补齐。
    ///
    /// 渲染色与背景色未配置时，分别沿用图片原色与单元格默认背景。
    var icon: WSPluginIcon {
        switch self {
        case .text:
            return .empty
        default:
            return WSPluginIcon(name: "plugin_\(rawValue)_48")
        }
    }

    /// 模块展示名称
    var displayName: String {
        return title
    }

    /// 所属模块组。选择器按组划分 section，组内按模块逐行展示。
    var group: WSPluginModuleGroup {
        switch self {
        case .todoListGroup, .todoTagGroup, .todoFilterGroup:
            return .todoGroup
        case .todoUserListTask, .todoSmartListTask, .todoTagTask, .todoFilterTask, .todoCustomTask:
            return .todoTask
        case .text, .separator:
            return .content
        case .myDay, .calendar, .timeline, .quadrants, .goal, .focus, .habit, .countdown, .action:
            return .others
        }
    }

    /// 该模块下的全部组件类型，按模块内的声明顺序排列。
    var types: [WSPluginType] {
        switch self {
        case .myDay: return WSPluginType.MyDay.all
        case .calendar: return WSPluginType.Calendar.all
        case .todoListGroup: return WSPluginType.TodoList.all
        case .todoUserListTask: return WSPluginType.TodoUserListTask.all
        case .todoSmartListTask: return WSPluginType.TodoSmartListTask.all
        case .todoTagGroup: return WSPluginType.TodoTag.all
        case .todoTagTask: return WSPluginType.TodoTagTask.all
        case .todoFilterGroup: return WSPluginType.TodoFilter.all
        case .todoFilterTask: return WSPluginType.TodoFilterTask.all
        case .todoCustomTask: return WSPluginType.TodoCustomTask.all
        case .timeline: return WSPluginType.Timeline.all
        case .quadrants: return WSPluginType.Quadrant.all
        case .goal: return WSPluginType.Goal.all
        case .focus: return WSPluginType.Focus.all
        case .habit: return WSPluginType.Habit.all
        case .countdown: return WSPluginType.Countdown.all
        case .text: return WSPluginType.Text.all
        case .separator: return WSPluginType.Separator.all
        case .action: return WSPluginType.Action.all
        }
    }

    // MARK: - 选择方式

    /// 模块在组件选择器中的选择方式。默认进入组件画廊，单组件模块可直接添加。
    var pickerStyle: WSPluginModulePickerStyle {
        switch self {
        case .text, .separator:
            return .directAdd
        default:
            return .gallery
        }
    }

    /// 直接添加时使用的组件，仅 `directAdd` 的模块有值。
    var directAddType: WSPluginType? {
        guard pickerStyle == .directAdd else {
            return nil
        }

        assert(types.count == 1, "直接添加的模块只能有一个组件：\(rawValue)")
        return types.first
    }

    /// 选择器中的预设变体。
    ///
    /// 非空时模块按变体展开成多行，每行直接添加同一组件并预设不同的配置，
    /// 例如文本的标题 / 正文两种字体样式共用一套组件。
    var pickerVariants: [WSPluginModuleVariant] {
        switch self {
        case .text:
            return WSPluginType.Text.styleVariants
        default:
            return []
        }
    }
}

// MARK: - 选择器变体

/// 模块在选择器中的预设变体。
///
/// 每个变体对应选择器中的一行，添加的组件类型不变，只是写入不同的组件配置。
struct WSPluginModuleVariant {

    /// 行标题
    let title: String

    /// 行图标。为 nil 时沿用模块图标，非 nil 字段覆盖模块图标的对应字段
    let icon: WSPluginIcon?

    /// 添加时写入的组件配置 JSON
    let configJSON: String?
}

// MARK: - 选择方式

/// 模块在组件选择器中的选择方式。
enum WSPluginModulePickerStyle {

    /// 进入组件画廊，选中后添加
    case gallery

    /// 直接添加模块内唯一的组件，无需进入画廊
    case directAdd
}

// MARK: - 插件模块组

/// 组件模块组。
///
/// 一个组对应选择器中的一个 section，组内模块逐行展示。
/// 待办按「清单/标签/过滤器」与「任务」拆成两个组，文本与分割线归入 `content`，
/// 其余模块统一归入 `others`；后续需要单独成组时，新增 case 并把对应模块的 `group` 指过来即可。
public enum WSPluginModuleGroup: String, CaseIterable {
    case content    /// 内容
    case todoGroup  /// 待办
    case todoTask   /// 待办任务
    case others    /// 其它

    /// 组标题
    var title: String {
        switch self {
        case .content: return resGetString("Content")
        case .todoGroup: return resGetString("Todo Groups")
        case .todoTask: return resGetString("Todo Tasks")
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
