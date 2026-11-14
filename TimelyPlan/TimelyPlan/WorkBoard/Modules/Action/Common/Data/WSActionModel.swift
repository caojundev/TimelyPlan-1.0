//
//  WSActionModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/13.
//

import Foundation
import UIKit

// MARK: - 动作方式

/// 动作方式
enum WSActionMode: String, Codable, CaseIterable, TPMenuRepresentable {

    /// 添加
    case add

    /// 跳转
    case navigate

    /// 方式标题，供分段选择展示
    static func titles() -> [String] {
        return ["Add", "Jump"]
    }
}

// MARK: - 添加动作

/// 添加动作类型
enum WSActionAddType: String, Codable, CaseIterable {

    /// 待办任务
    case todoTask
    
    /// 待办列表
    case todoList

    /// 待办标签
    case todoTag

    /// 待办过滤器
    case todoFilter

    /// 目标计划
    case goalPlan

    /// 目标任务
    case goalTask

    /// 日历事项
    case calendarEvent

    /// 习惯任务
    case habitTask

    /// 计时器
    case timer

    /// 倒数日
    case countdown

    /// 展示名称
    var title: String {
        switch self {
        case .calendarEvent: return resGetString("Calendar Event")
        case .todoList: return resGetString("Todo List")
        case .todoTag: return resGetString("Todo Tag")
        case .todoFilter: return resGetString("Todo Filter")
        case .todoTask: return resGetString("Todo Task")
        case .goalPlan: return resGetString("Goal Plan")
        case .goalTask: return resGetString("Goal Task")
        case .habitTask: return resGetString("Habit Task")
        case .timer: return resGetString("Timer")
        case .countdown: return resGetString("Countdown")
        }
    }

    /// 所属分组。编辑界面按分组各展示一个区块
    var group: WSActionAddGroup {
        switch self {
        case .todoList, .todoTag, .todoFilter, .todoTask:
            return .todo
        case .goalPlan, .goalTask:
            return .goal
        case .calendarEvent, .habitTask, .timer, .countdown:
            return .others
        }
    }
}

// MARK: - 添加动作分组

/// 添加动作的分组
enum WSActionAddGroup: CaseIterable {

    /// 待办
    case todo

    /// 目标
    case goal

    /// 其它
    case others
}

// MARK: - 跳转动作

extension SideMenuType {

    /// 可作为跳转目标的模块，排除工作台与设置
    static var actionTargets: [SideMenuType] {
        return [.myDay, .calendar, .todo, .timeline, .quadrants,
                .goal, .focus, .habit, .countdown]
    }

    /// 是否可作为动作的跳转目标
    var isActionTarget: Bool {
        return SideMenuType.actionTargets.contains(self)
    }
}

// MARK: - 动作

/// 单个动作。同时作为行视图的数据条目传给交互器
struct WSActionItem: Codable, WSPluginDataItem {

    /// 自定义颜色。为空时使用主题色
    var colorHex: String?

    /// 动作方式
    var mode: WSActionMode

    /// 添加动作类型，`mode` 为 `add` 时有值
    var addType: WSActionAddType?

    /// 跳转目标，`mode` 为 `navigate` 时有值
    var sideMenuType: SideMenuType?

    init(colorHex: String? = nil,
         mode: WSActionMode,
         addType: WSActionAddType? = nil,
         sideMenuType: SideMenuType? = nil) {
        self.colorHex = colorHex
        self.mode = mode
        self.addType = addType
        self.sideMenuType = sideMenuType
    }

    /// 自定义颜色
    var color: UIColor? {
        guard let colorHex = colorHex else {
            return nil
        }

        return UIColor(RGBString: colorHex)
    }

    /// 展示名称
    var title: String {
        switch mode {
        case .add:
            return addType?.title ?? ""
        case .navigate:
            return sideMenuType?.title ?? ""
        }
    }

    /// 是否配置完整，可以执行
    var isValid: Bool {
        switch mode {
        case .add:
            return addType != nil
        case .navigate:
            return sideMenuType?.isActionTarget ?? false
        }
    }
}

// MARK: - 可选颜色

extension WSActionItem {

    /// 自定义颜色候选，顺序即颜色选择器的展示顺序
    static let colors = [Color(0x4A4DFF),
                         Color(0xFFB43E),
                         Color(0xF66464),
                         Color(0xD8451B),
                         Color(0x0C7B59),
                         Color(0x8F3986),
                         Color(0xCC7173),
                         Color(0xFFA14E),
                         Color(0x0BBDB8)]

    /// 默认颜色
    static var defaultColor: UIColor {
        return colors[0]
    }
}

// MARK: - 配置

/// 动作组件的配置
struct WSActionConfiguration: Codable {

    /// 用户选中并排序的动作
    var actions: [WSActionItem]?
}
