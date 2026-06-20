//
//  CoreDataEntityChangeConverter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/20.
//

import Foundation
import CoreData


// MARK: - 实体转换协议
protocol CoreDataEntityConvertible {
    associatedtype CoreDataType: NSManagedObject
    associatedtype DomainType
    
    static func fromCoreData(_ object: CoreDataType) -> DomainType?
    static var entityName: String { get }
}

// MARK: - 实体转换结果
struct EntityChangeResults<T> {
    let inserted: [T]
    let updated: [T]
    let deletedObjectIDs: [NSManagedObjectID]
    
    var hasChanges: Bool { !inserted.isEmpty || !updated.isEmpty || !deletedObjectIDs.isEmpty }
    var totalChanges: Int { inserted.count + updated.count + deletedObjectIDs.count }
}

// MARK: - 实体转换器
class EntityChangeConverter {
    
    static let shared = EntityChangeConverter()
    private init() {}
    
    func convert<T: CoreDataEntityConvertible>(
        changes: CoreDataRemoteChangeManager.EntityChanges,
        converterType: T.Type
    ) -> EntityChangeResults<T.DomainType> {
        
        let context = NSManagedObjectContext.defaultContext
        
        let insertedItems = changes.inserted.compactMap { objectID -> T.DomainType? in
            guard let object = try? context.existingObject(with: objectID),
                  let coreDataObject = object as? T.CoreDataType else { return nil }
            return T.fromCoreData(coreDataObject)
        }
        
        let updatedItems = changes.updated.compactMap { objectID -> T.DomainType? in
            guard let object = try? context.existingObject(with: objectID),
                  let coreDataObject = object as? T.CoreDataType else { return nil }
            return T.fromCoreData(coreDataObject)
        }
        
        return EntityChangeResults(
            inserted: insertedItems,
            updated: updatedItems,
            deletedObjectIDs: Array(changes.deleted)
        )
    }
}

// MARK: - 所有实体转换器
// FocusTimer
struct FocusTimerConverter: CoreDataEntityConvertible {
    typealias CoreDataType = CDFocusTimer
    typealias DomainType = FocusTimer
    static var entityName: String { EntityName.focusTimer.rawValue }
    static func fromCoreData(_ object: CDFocusTimer) -> FocusTimer? { FocusTimer(content: object) }
}

// FocusSession
struct FocusSessionConverter: CoreDataEntityConvertible {
    typealias CoreDataType = CDFocusSession
    typealias DomainType = FocusSession
    static var entityName: String { EntityName.focusSession.rawValue }
    static func fromCoreData(_ object: CDFocusSession) -> FocusSession? { FocusSession(content: object) }
}

// HabitRecord
struct HabitRecordConverter: CoreDataEntityConvertible {
    typealias CoreDataType = CDHabitRecord
    typealias DomainType = HabitRecord
    static var entityName: String { EntityName.habitRecord.rawValue }
    static func fromCoreData(_ object: CDHabitRecord) -> HabitRecord? { HabitRecord(content: object) }
}

// HabitSample
struct HabitSampleConverter: CoreDataEntityConvertible {
    typealias CoreDataType = CDHabitSample
    typealias DomainType = HabitSample
    static var entityName: String { EntityName.habitSample.rawValue }
    static func fromCoreData(_ object: CDHabitSample) -> HabitSample? { HabitSample(content: object) }
}

// HabitTask
struct HabitTaskConverter: CoreDataEntityConvertible {
    typealias CoreDataType = CDHabitTask
    typealias DomainType = HabitTask
    static var entityName: String { EntityName.habitTask.rawValue }
    static func fromCoreData(_ object: CDHabitTask) -> HabitTask? { HabitTask(content: object) }
}

// TodoFilter
struct TodoFilterConverter: CoreDataEntityConvertible {
    typealias CoreDataType = CDTodoFilter
    typealias DomainType = TodoFilter
    static var entityName: String { EntityName.todoFilter.rawValue }
    static func fromCoreData(_ object: CDTodoFilter) -> TodoFilter? { TodoFilter(content: object) }
}

// TodoList
struct TodoListConverter: CoreDataEntityConvertible {
    typealias CoreDataType = CDTodoList
    typealias DomainType = TodoList
    static var entityName: String { EntityName.todoList.rawValue }
    static func fromCoreData(_ object: CDTodoList) -> TodoList? {
        guard let identifier = object.identifier else {
            return nil
        }
        
        return TodoRepository.getUserList(of: identifier)
    }
}

// TodoSection
struct TodoSectionConverter: CoreDataEntityConvertible {
    typealias CoreDataType = CDTodoSection
    typealias DomainType = TodoSection
    static var entityName: String { EntityName.todoSection.rawValue }
    static func fromCoreData(_ object: CDTodoSection) -> TodoSection? { TodoSection(content: object) }
}

// TodoTag
struct TodoTagConverter: CoreDataEntityConvertible {
    typealias CoreDataType = CDTodoTag
    typealias DomainType = TodoTag
    static var entityName: String { EntityName.todoTag.rawValue }
    static func fromCoreData(_ object: CDTodoTag) -> TodoTag? { TodoTag(content: object) }
}

// TodoTask
struct TodoTaskConverter: CoreDataEntityConvertible {
    typealias CoreDataType = CDTodoTask
    typealias DomainType = TodoTask
    static var entityName: String { EntityName.todoTask.rawValue }
    static func fromCoreData(_ object: CDTodoTask) -> TodoTask? { TodoTask(content: object) }
}

// KeyValueStore
struct KeyValueStoreConverter: CoreDataEntityConvertible {
    typealias CoreDataType = KeyValueEntry
    typealias DomainType = KeyValueEntry
    static var entityName: String { EntityName.keyValueStore.rawValue }
    static func fromCoreData(_ object: KeyValueEntry) -> KeyValueEntry? { return object }
}

// MARK: - 实体转换器注册表
class EntityConverterRegistry {
    
    static let shared = EntityConverterRegistry()
    
    private var converterMap: [EntityName: (CoreDataRemoteChangeManager.EntityChanges) -> Any] = [:]
    
    private init() {
        registerAll()
    }
    
    private func registerAll() {
        register(.focusTimer, converter: FocusTimerConverter.self)
        register(.focusSession, converter: FocusSessionConverter.self)
        register(.habitRecord, converter: HabitRecordConverter.self)
        register(.habitSample, converter: HabitSampleConverter.self)
        register(.habitTask, converter: HabitTaskConverter.self)
        register(.todoFilter, converter: TodoFilterConverter.self)
        register(.todoList, converter: TodoListConverter.self)
        register(.todoSection, converter: TodoSectionConverter.self)
        register(.todoTag, converter: TodoTagConverter.self)
        register(.todoTask, converter: TodoTaskConverter.self)
        register(.keyValueStore, converter: KeyValueStoreConverter.self)
    }
    
    func register<T: CoreDataEntityConvertible>(_ entityName: EntityName, converter: T.Type) {
        converterMap[entityName] = { changes in
            EntityChangeConverter.shared.convert(changes: changes, converterType: converter)
        }
    }
    
    func convert<T: CoreDataEntityConvertible>(
        _ entityName: EntityName,
        changes: CoreDataRemoteChangeManager.EntityChanges,
        converterType: T.Type
    ) -> EntityChangeResults<T.DomainType> {
        return EntityChangeConverter.shared.convert(changes: changes, converterType: converterType)
    }
    
    /// 自动转换所有变更
    func convertAll(from changeInfo: CoreDataRemoteChangeManager.ChangeInfo) -> [EntityName: Any] {
        var results: [EntityName: Any] = [:]
        
        for (entityNameString, changes) in changeInfo.changesByEntity {
            guard let entityName = EntityName(rawValue: entityNameString),
                  let converter = converterMap[entityName] else { continue }
            results[entityName] = converter(changes)
        }
        
        return results
    }
}

// MARK: - 便捷的 ChangeInfo 扩展
extension CoreDataRemoteChangeManager.ChangeInfo {
    
    func extractChanges<T: CoreDataEntityConvertible>(
        for entityName: EntityName,
        converterType: T.Type
    ) -> EntityChangeResults<T.DomainType>? {
        guard let changes = self.changes(for: entityName) else { return nil }
        return EntityChangeConverter.shared.convert(changes: changes, converterType: converterType)
    }
    
    func extractFocusTimer() -> EntityChangeResults<FocusTimer>? {
        guard let changes = changesByEntity[EntityName.focusTimer.rawValue] else { return nil }
        return EntityChangeConverter.shared.convert(changes: changes, converterType: FocusTimerConverter.self)
    }
    
    func extractFocusSession() -> EntityChangeResults<FocusSession>? {
        guard let changes = changesByEntity[EntityName.focusSession.rawValue] else { return nil }
        return EntityChangeConverter.shared.convert(changes: changes, converterType: FocusSessionConverter.self)
    }
    
    func extractHabitRecord() -> EntityChangeResults<HabitRecord>? {
        guard let changes = changesByEntity[EntityName.habitRecord.rawValue] else { return nil }
        return EntityChangeConverter.shared.convert(changes: changes, converterType: HabitRecordConverter.self)
    }
    
    func extractHabitSample() -> EntityChangeResults<HabitSample>? {
        guard let changes = changesByEntity[EntityName.habitSample.rawValue] else { return nil }
        return EntityChangeConverter.shared.convert(changes: changes, converterType: HabitSampleConverter.self)
    }
    
    func extractHabitTask() -> EntityChangeResults<HabitTask>? {
        guard let changes = changesByEntity[EntityName.habitTask.rawValue] else { return nil }
        return EntityChangeConverter.shared.convert(changes: changes, converterType: HabitTaskConverter.self)
    }
    
    func extractTodoFilter() -> EntityChangeResults<TodoFilter>? {
        guard let changes = changesByEntity[EntityName.todoFilter.rawValue] else { return nil }
        return EntityChangeConverter.shared.convert(changes: changes, converterType: TodoFilterConverter.self)
    }
    
    func extractTodoList() -> EntityChangeResults<TodoList>? {
        guard let changes = changesByEntity[EntityName.todoList.rawValue] else { return nil }
        return EntityChangeConverter.shared.convert(changes: changes, converterType: TodoListConverter.self)
    }
    
    func extractTodoSection() -> EntityChangeResults<TodoSection>? {
        guard let changes = changesByEntity[EntityName.todoSection.rawValue] else { return nil }
        return EntityChangeConverter.shared.convert(changes: changes, converterType: TodoSectionConverter.self)
    }
    
    func extractTodoTag() -> EntityChangeResults<TodoTag>? {
        guard let changes = changesByEntity[EntityName.todoTag.rawValue] else { return nil }
        return EntityChangeConverter.shared.convert(changes: changes, converterType: TodoTagConverter.self)
    }
    
    func extractTodoTask() -> EntityChangeResults<TodoTask>? {
        guard let changes = changesByEntity[EntityName.todoTask.rawValue] else { return nil }
        return EntityChangeConverter.shared.convert(changes: changes, converterType: TodoTaskConverter.self)
    }
    
    func extractKeyValueStore() -> EntityChangeResults<KeyValueEntry>? {
        guard let changes = changesByEntity[EntityName.keyValueStore.rawValue] else { return nil }
        return EntityChangeConverter.shared.convert(changes: changes, converterType: KeyValueStoreConverter.self)
    }
}
