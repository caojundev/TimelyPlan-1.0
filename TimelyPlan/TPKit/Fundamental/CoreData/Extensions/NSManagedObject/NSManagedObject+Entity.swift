//
//  NSManagedObject+Entity.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/12.
//

import Foundation
import CoreData

// MARK: - 实体描述与属性管理

extension NSManagedObject {
    
    // MARK: 实体基础信息
    
    /// 默认实体名称，使用类名作为实体名
    /// 子类可以重写此属性以自定义实体名称
    class var entityName: String {
        return String(describing: Self.self)
    }

    /// 获取默认上下文中的实体描述
    /// - Returns: 实体描述对象，如果实体不存在则返回 nil
    class func entityDescription() -> NSEntityDescription? {
        let context = NSManagedObjectContext.defaultContext
        return entityDescription(in: context)
    }
    
    /// 获取指定上下文中的实体描述
    /// - Parameter context: 托管对象上下文
    /// - Returns: 实体描述对象，如果实体不存在则返回 nil
    class func entityDescription(in context: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName, in: context)
    }
 
    // MARK: 属性查询
    
    /// 在默认上下文中获取指定名称的属性描述数组
    /// - Parameter names: 属性名称数组
    /// - Returns: 属性描述数组，如果实体描述不存在则返回 nil
    class func properties(names: [String]) -> [NSPropertyDescription]? {
        let context = NSManagedObjectContext.defaultContext
        return properties(names: names, in: context)
    }
    
    /// 在指定上下文中获取属性描述数组
    /// - Parameters:
    ///   - names: 属性名称数组
    ///   - context: 托管对象上下文
    /// - Returns: 匹配的属性描述数组，如果未找到任何匹配属性则返回空数组
    class func properties(names: [String], in context: NSManagedObjectContext) -> [NSPropertyDescription]? {
        guard let entityDescription = entityDescription(in: context),
              !names.isEmpty else {
            debugPrint("实体描述不存在或属性名称为空")
            return []
        }
        
        let propertiesByName = entityDescription.propertiesByName
        var result = [NSPropertyDescription]()
        
        for name in names {
            if let propertyDescription = propertiesByName[name] {
                result.append(propertyDescription)
            } else {
                debugPrint("属性 '\(name)' 未在实体 '\(entityName)' 的 \(propertiesByName.count) 个属性中找到")
            }
        }
        
        return result
    }

    // MARK: 排序描述符生成
    
    /// 根据指定键名和排序方向创建排序描述符数组
    /// - Parameters:
    ///   - ascending: 是否升序排列
    ///   - keys: 排序键名数组
    /// - Returns: 排序描述符数组
    class func sortDescriptors(ascending: Bool, keys: [String]) -> [NSSortDescriptor] {
        return keys.map { NSSortDescriptor(key: $0, ascending: ascending) }
    }
    
    /// 创建升序排序描述符
    /// - Parameter keys: 排序键名数组
    /// - Returns: 升序排序描述符数组
    class func ascendingSortDescriptors(keys: [String]) -> [NSSortDescriptor] {
        return sortDescriptors(ascending: true, keys: keys)
    }
      
    /// 创建降序排序描述符
    /// - Parameter keys: 排序键名数组
    /// - Returns: 降序排序描述符数组
    class func descendingSortDescriptors(keys: [String]) -> [NSSortDescriptor] {
        return sortDescriptors(ascending: false, keys: keys)
    }
}

// MARK: - 实体生命周期管理

extension NSManagedObject {
    
    // MARK: 实体创建
    
    /// 在指定上下文中创建当前实体的新实例
    /// - Parameter context: 托管对象上下文
    /// - Returns: 新创建的实体实例
    /// - Note: 使用默认实体名称
    class func createEntity(in context: NSManagedObjectContext) -> Self {
        guard let entity = entityDescription(in: context) else {
            fatalError("无法创建实体 '\(entityName)' 的描述")
        }
        return Self(entity: entity, insertInto: context)
    }
    
    /// 使用自定义实体名称在指定上下文中创建实体实例
    /// - Parameters:
    ///   - name: 实体名称
    ///   - context: 托管对象上下文
    /// - Returns: 新创建的实体实例
    /// - Note: 适用于实体名称与类名不同的情况
    class func createEntity(forEntityName name: String, in context: NSManagedObjectContext) -> Self {
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: context) else {
            fatalError("无法创建实体 '\(name)' 的描述")
        }
        return Self(entity: entity, insertInto: context)
    }
                    
    // MARK: 跨上下文对象访问
    
    /// 在其他上下文中获取当前对象的对应实例
    /// - Parameter otherContext: 目标托管对象上下文
    /// - Returns: 目标上下文中的对应对象，如果获取失败则返回 nil
    /// - Note: 自动处理临时对象ID到永久ID的转换
    func inContext(otherContext: NSManagedObjectContext) -> NSManagedObject? {
        // 处理临时对象ID：临时ID意味着对象尚未保存到持久化存储
        if self.objectID.isTemporaryID {
            do {
                // 尝试获取永久ID，使对象可以在不同上下文间安全传递
                try self.managedObjectContext?.obtainPermanentIDs(for: [self])
            } catch {
                debugPrint("获取永久ID失败: \(error.localizedDescription)")
                return nil
            }
        }

        // 在目标上下文中查找对应对象
        do {
            let object = try otherContext.existingObject(with: self.objectID)
            return object
        } catch {
            debugPrint("在目标上下文中获取对象失败: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: 实体删除操作
    
    /// 在指定上下文中删除当前实体
    /// - Parameter context: 托管对象上下文
    /// - Returns: 删除是否成功
    func deleteEntity(in context: NSManagedObjectContext) -> Bool {
        do {
            let object = try context.existingObject(with: self.objectID)
            context.delete(object)
            return true
        } catch {
            debugPrint("删除实体失败: \(error.localizedDescription)")
            return false
        }
    }

    /// 在当前托管对象上下文中删除实体
    /// - Returns: 删除是否成功，如果对象未关联上下文则返回 false
    func deleteEntity() -> Bool {
        guard let context = managedObjectContext else {
            debugPrint("对象未关联托管对象上下文")
            return false
        }
        
        return self.deleteEntity(in: context)
    }
    
    // MARK: 批量删除操作
    
    /// 删除符合谓词条件的所有实体
    /// - Parameters:
    ///   - predicate: 过滤谓词
    ///   - context: 托管对象上下文
    /// - Returns: 删除操作是否成功
    class func truncateAll(matchingPredicate predicate: NSPredicate,
                           in context: NSManagedObjectContext) -> Bool {
        let request = fetchAllRequest(with: predicate, in: context)
        return truncate(with: request, in: context)
    }
    
    /// 删除当前实体的所有实例
    /// - Parameter context: 托管对象上下文
    /// - Returns: 删除操作是否成功
    class func truncateAll(in context: NSManagedObjectContext) -> Bool {
        let request = fetchAllRequest(in: context)
        return truncate(with: request, in: context)
    }
    
    // MARK: 私有辅助方法
    
    /// 执行批量删除操作的核心方法
    /// - Parameters:
    ///   - request: 获取请求配置
    ///   - context: 托管对象上下文
    /// - Returns: 删除操作是否成功
    private class func truncate(with request: NSFetchRequest<NSFetchRequestResult>,
                                in context: NSManagedObjectContext) -> Bool {
        // 优化性能：仅获取对象ID，减少内存占用
        request.returnsObjectsAsFaults = true
        request.includesPropertyValues = false
        
        guard let objectsToTruncate = executeFetchRequest(request, in: context) as? [NSManagedObject],
              !objectsToTruncate.isEmpty else {
            debugPrint("未找到需要删除的对象")
            return false
        }
        
        // 逐个删除对象
        var allDeleted = true
        for objectToTruncate in objectsToTruncate {
            if !objectToTruncate.deleteEntity(in: context) {
                allDeleted = false
                debugPrint("删除对象失败: \(objectToTruncate.objectID)")
            }
        }
        
        return allDeleted
    }
}
