//
//  WSTodoSmartListTasksContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation

// MARK: - 内容交互器

/// 待办自选智能清单任务组件的内容交互器。
///
/// 读取配置中选中的智能清单及其未完成任务；任务或跨天变化时重新取数，
/// 点击任务与完成状态沿用待办任务交互器基类。
class WSTodoSmartListTasksContentInteractor: WSTodoGroupTasksContentInteractor {
    
    /// 用户选中的智能清单类型
    private var selectedListType: TodoSmartListType? {
        guard let identifier = plugin.configuration(as: WSTodoSmartListSelectedSmartListConfiguration.self)?.smartListIdentifier else {
            return nil
        }
        
        return TodoSmartListType(rawValue: identifier)
    }
    
    // MARK: - 取数
    /// 读取选中的智能清单与其中的未完成任务。未配置时不展示内容
    override func fetchGroup(completion: @escaping (WSTodoTaskGroup?) -> Void) {
        guard let listType = selectedListType else {
            /// 用户未选择智能清单时交给空白内容视图
            completion(nil)
            return
        }
        
        let list = TodoSmartList(type: listType)
        TodoRepository.fetchSmartListTasks(in: list, showCompleted: false) { tasks in
            let icon = list.iconName.map { TPIcon(name: $0) }
            let info = WSTodoGroupInfo(title: list.title, icon: icon, color: list.color)
            completion(WSTodoTaskGroup(info: info, tasks: tasks ?? []))
        }
    }
    
    // MARK: - 交互
    /// 打开所选智能清单的详情
    override func openDetail() {
        guard let listType = selectedListType else {
            return
        }
        
        WSTodoListDetailPresenter.showDetail(for: TodoSmartList(type: listType))
    }
    
    // MARK: - 预览数据
    override func previewGroupInfo() -> WSTodoGroupInfo? {
        let list = TodoSmartList(type: .upcoming)
        let icon = list.iconName.map { TPIcon(name: $0) }
        return WSTodoGroupInfo(title: list.title, icon: icon, color: list.color)
    }
    
    // MARK: - 零点更新
    /// 已过期、今天、明天、接下来都与日期相关，跨天后任务归属会变化；
    /// 收件箱与我的一天不随日期变化，无需刷新
    override func updateAtMidnight() {
        guard selectedListType?.isScheduleType == true else {
            return
        }
        
        super.updateAtMidnight()
    }
}
