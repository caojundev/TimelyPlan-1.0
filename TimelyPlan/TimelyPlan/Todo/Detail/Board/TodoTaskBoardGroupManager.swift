//
//  TodoTaskBoardGroupManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/2.
//

import Foundation

class TodoTaskBoardGroupManager {
    
    let interactor: TodoListInteractor
    
    init(interactor: TodoListInteractor) {
        self.interactor = interactor
    }
    
    private let hiddenAddGroupIds = [TodoTaskDueDateType.overdue.identifier,
                                     TodoTaskStaus.completed.identifier,
                                     TodoGroupType.none.identifier]

    
    /// 分组是否显示添加按钮
    func shouldShowAdd(for group: TodoGroup) -> Bool {
        if hiddenAddGroupIds.contains(group.identifier) {
            return false
        }
        
        return true
    }
    
    // MARK: - 拖放验证
    func canDrag(from source: TodoGroup) -> Bool {
        let disabledGroupTypes: [TodoGroupType] = [.completionDate]
        return !disabledGroupTypes.contains(interactor.groupType)
    }
    
    func canDrop(_ task: TodoTask, from source: TodoGroup, to destination: TodoGroup) -> Bool {
        let disabledGroupIds = [TodoTaskStartDateType.started.identifier,
                                TodoTaskDueDateType.overdue.identifier]
        return !disabledGroupIds.contains(destination.identifier)
    }
    
    func canInsert(_ task: TodoTask, from source: TodoGroup, to destination: TodoGroup, at index: Int) -> Bool {
        /// 仅用户列表和收件箱支持插入排序
        guard interactor is TodoUserListInteractor ||
                interactor is TodoSmartListInteractor else {
            return false
        }
        
        /// 手动排序
        if interactor.sort.type == .manually {
            return true
        }
        
        return false
    }

    // MARK: - 执行插入
    func insert(_ task: TodoTask, from source: TodoGroup, to destination: TodoGroup, at index: Int? = nil) {
        drop(task, from: source, to: destination)
        if let index = index {
            performReorder(task, from: source, to: destination, at: index)
        }
    }
    
    private func drop(_ task: TodoTask, from source: TodoGroup, to destination: TodoGroup) {
        guard source.identifier != destination.identifier else {
            return
        }
        
        let groupType = interactor.groupType
        switch groupType {
        case .default:
            handleDefaultDrop(task, from: source, to: destination)
        case .priority:
            handlePriorityDrop(task, from: source, to: destination)
        case .startDate:
            handleStartDateDrop(task, from: source, to: destination)
        case .dueDate:
            handleDueDateDrop(task, from: source, to: destination)
        case .custom:
            handleCustomDrop(task, from: source, to: destination)
        case .list:
            break
        case .none:
            break
        case .completionDate:
            break
        }
    }

    private func handleDefaultDrop(_ task: TodoTask, from source: TodoGroup, to destination: TodoGroup) {
        guard let status = TodoTaskStaus(identifier: destination.identifier) else {
            return
        }
        
        let isCompleted = status == .completed
        TodoRepository.updateTasks([task], isCompleted: isCompleted)
    }

    private func handleStartDateDrop(_ task: TodoTask, from source: TodoGroup, to destination: TodoGroup) {
        guard let dateType = TodoTaskStartDateType(identifier: destination.identifier) else {
            return
        }
        
        var newSchedule = TaskSchedule.schedule(for: dateType)
        if let newDateInfo = newSchedule?.dateInfo,
           let oldSchedule = task.schedule,
           let oldDateInfo = oldSchedule.dateInfo {

            /// 替换开始日期天
            let editor: TodoDateInfoEditable
            if oldDateInfo.style == .singleDay {
                editor = TodoSingleDateInfoEditor(dateInfo: oldDateInfo)
            } else {
                editor = TodoMultiDateInfoEditor(dateInfo: oldDateInfo)
            }

            editor.setDate(newDateInfo.startDate, editType: .start)
            newSchedule?.dateInfo = editor.dateInfo
            newSchedule?.reminder = oldSchedule.reminder
            newSchedule?.repeatRule = oldSchedule.repeatRule
        }
        
        TodoRepository.updateTask(task, schedule: newSchedule)
    }

    private func handleDueDateDrop(_ task: TodoTask, from source: TodoGroup, to destination: TodoGroup) {
        guard let dateType = TodoTaskDueDateType(identifier: destination.identifier) else {
            return
        }
        
        var newSchedule = TaskSchedule.schedule(for: dateType)
        if let newDateInfo = newSchedule?.dateInfo,
           let oldSchedule = task.schedule,
           let oldDateInfo = oldSchedule.dateInfo {

            /// 替换开始日期天
            let editor: TodoDateInfoEditable
            if oldDateInfo.style == .singleDay {
                editor = TodoSingleDateInfoEditor(dateInfo: oldDateInfo)
            } else {
                editor = TodoMultiDateInfoEditor(dateInfo: oldDateInfo)
            }

            editor.setDate(newDateInfo.endDate, editType: .end)
            newSchedule?.dateInfo = editor.dateInfo
            newSchedule?.reminder = oldSchedule.reminder
            newSchedule?.repeatRule = oldSchedule.repeatRule
        }
        
        TodoRepository.updateTask(task, schedule: newSchedule)
    }

    private func handlePriorityDrop(_ task: TodoTask, from source: TodoGroup, to destination: TodoGroup) {
        if let priority = TodoTaskPriority(identifier: destination.identifier) {
            TodoRepository.updateTasks([task], priority: priority)
        }
    }

    private func handleCustomDrop(_ task: TodoTask, from source: TodoGroup, to destination: TodoGroup) {
        if let section = destination.dataItem as? TodoSectionFeature {
            TodoRepository.moveTasks([task], to: section)
        }
    }

    // MARK: - 辅助方法

    /// 执行任务重新排序的完整逻辑
    private func performReorder(_ task: TodoTask, from source: TodoGroup, to destination: TodoGroup, at index: Int) {
        // 1. 计算插入位置和目标任务
        guard let reorderInfo = calculateReorderInfo(
            task: task,
            from: source,
            to: destination,
            at: index
        ) else {
            return
        }
        
        // 2. 获取关联的列表
        guard let list = getAssociatedList() else {
            return
        }
        
        // 3. 执行排序操作
        TodoRepository.reorderTask(
            task,
            postion: reorderInfo.position,
            targetTask: reorderInfo.targetTask,
            in: list
        )
    }

    /// 计算重排序所需的信息
    private func calculateReorderInfo(
        task: TodoTask,
        from source: TodoGroup,
        to destination: TodoGroup,
        at index: Int
    ) -> (targetTask: TodoTask, position: TodoTaskInsertPosition)? {
        
        var insertPosition: TodoTaskInsertPosition = .after
        var targetTask: TodoTask?
        
        if source.identifier == destination.identifier {
            // 相同分组内移动
            guard let sourceIndex = source.index(of: task), sourceIndex != index else {
                return nil
            }
            
            targetTask = destination.task(at: index)
            if sourceIndex > index {
                insertPosition = .before
            }
        } else {
            // 跨分组移动
            let tasksCount = destination.tasks?.count ?? 0
            if index < tasksCount {
                targetTask = destination.task(at: index)
                insertPosition = .before
            } else {
                targetTask = destination.task(at: tasksCount - 1)
            }
        }
        
        guard let targetTask = targetTask else {
            return nil
        }
        
        return (targetTask, insertPosition)
    }
    
    /// 获取关联的列表对象
    private func getAssociatedList() -> TodoList? {
        if let interactor = interactor as? TodoUserListInteractor {
            return interactor.list
        }
        return nil
    }

}
