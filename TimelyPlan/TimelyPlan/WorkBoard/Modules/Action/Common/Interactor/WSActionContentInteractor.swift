//
//  WSActionContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/14.
//

import Foundation
import UIKit

// MARK: - 内容交互器

/// 动作组件的内容交互器。点击行时按动作方式执行添加或跳转。
class WSActionContentInteractor: WSPluginContentInteractor {

    /// 待办快速添加管理器。输入视图依附于顶层视图控制器，需要持续持有
    private var quickAddManager: TodoTaskQuickAddManager?

    /// 最多展示的动作数目，与内容视图的展示条数保持一致
    private let maximumItemCount: Int

    init(plugin: WSPlugin, context: WSPluginContext, maximumItemCount: Int) {
        self.maximumItemCount = max(maximumItemCount, 1)
        super.init(plugin: plugin, context: context)
    }

    /// 配置中可执行的动作
    private var actions: [WSActionItem] {
        let actions = plugin.configuration(as: WSActionConfiguration.self)?.actions ?? []
        return Array(actions.filter { $0.isValid }.prefix(maximumItemCount))
    }

    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let actions = actions
        completion(actions.isEmpty ? nil : WSActionListDataItem(actions: actions))
    }

    // MARK: - 交互
    /// 动作由行视图触发，组件主体的点击不响应，避免与行内点击重复
    override func performAction(with dataItem: WSPluginDataItem) {
        guard let action = dataItem as? WSActionItem else {
            return
        }

        perform(action)
    }

    private func perform(_ action: WSActionItem) {
        switch action.mode {
        case .add:
            guard let addType = action.addType else {
                return
            }

            performAdd(addType)
        case .navigate:
            guard let menuType = action.sideMenuType, menuType.isActionTarget else {
                return
            }

            navigate(to: menuType)
        }
    }

    // MARK: - 添加
    private func performAdd(_ addType: WSActionAddType) {
        switch addType {
        case .calendarEvent:
            CalendarSystemManager.shared.createNewEvent(with: TaskDateInfo(date: .now))
        case .todoList:
            TodoUserListController().createList()
        case .todoTag:
            TodoTagController().createTag()
        case .todoFilter:
            TodoFilterController().createFilter()
        case .todoTask:
            showQuickAddTask()
        case .goalPlan:
            GoalPresenter.createNewGoalPlan()
        case .goalTask:
            GoalPresenter.createNewInboxGoalTask()
        case .habitTask:
            HabitPresenter.createNewHabitTask()
        case .timer:
            FocusPresenter.createNewTimer()
        case .countdown:
            CountdownPresenter.createNewEvent()
        }
    }

    /// 待办任务使用键盘跟手的快速添加输入视图
    private func showQuickAddTask() {
        guard let viewController = UIViewController.topPresented else {
            return
        }

        let manager = TodoTaskQuickAddManager(containerViewController: viewController)
        quickAddManager = manager

        let task = TodoQuickAddTask()
        task.isAddedToMyDay = true
        manager.show(with: task)
    }

    // MARK: - 跳转
    /// 切换到指定的侧边栏模块
    private func navigate(to menuType: SideMenuType) {
        guard let mainViewController = UIWindow.keyWindow?.rootViewController as? MainViewController else {
            return
        }

        mainViewController.jump(to: menuType)
    }

    // MARK: - 预览数据
    /// 画廊预览数据：同时展示添加与跳转两种动作，每个动作使用不同颜色
    override func previewDataItem() -> WSPluginDataItem? {
        let colors = WSActionItem.colors
        let previewActions = [
            WSActionItem(colorHex: colors[0].hexString, mode: .add, addType: .calendarEvent),
            WSActionItem(colorHex: colors[1].hexString, mode: .add, addType: .todoTask),
            WSActionItem(colorHex: colors[2].hexString, mode: .navigate, sideMenuType: .calendar),
            WSActionItem(colorHex: colors[3].hexString, mode: .navigate, sideMenuType: .habit),
            WSActionItem(colorHex: colors[4].hexString, mode: .add, addType: .todoList),
            WSActionItem(colorHex: colors[5].hexString, mode: .add, addType: .goalTask),
            WSActionItem(colorHex: colors[6].hexString, mode: .navigate, sideMenuType: .goal),
            WSActionItem(colorHex: colors[7].hexString, mode: .navigate, sideMenuType: .focus),
        ]

        return WSActionListDataItem(actions: Array(previewActions.prefix(maximumItemCount)))
    }
}
