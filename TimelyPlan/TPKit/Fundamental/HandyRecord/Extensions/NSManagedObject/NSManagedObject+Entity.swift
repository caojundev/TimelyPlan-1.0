//
//  NSManagedObject+Entity.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/12.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    /// 默认EntityName为类名称
    class var entityName: String {
        return String(describing: Self.self)
    }

    /// 获取实体描述
    class func entityDescription() -> NSEntityDescription? {
        let context = NSManagedObjectContext.defaultContext
        return entityDescription(in: context)
    }
    
    class func entityDescription(in context: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName, in: context)
    }
 
    // MARK: - Properties To Fetch
    class func properties(names: [String]) -> [NSPropertyDescription]? {
        let context = NSManagedObjectContext.defaultContext
        return properties(names: names, in: context)
    }
    
    class func properties(names: [String], in context: NSManagedObjectContext) -> [NSPropertyDescription]? {
        let entityDescription = entityDescription(in: context)
        var result = [NSPropertyDescription]()
        if names.count > 0, let dic = entityDescription?.propertiesByName {
            for name in names {
                if let propertyDescription = dic[name] {
                    result.append(propertyDescription)
                } else {
                    debugPrint("Property '\(name)' not found in \(dic.count) properties for\(String(describing: self))");
                }
            }
        }
        
        return result
    }

    // MARK: - Sort Descriptor
    class func sortDescriptors(ascending: Bool, keys: [String]) -> [NSSortDescriptor] {
        var descriptors: [NSSortDescriptor] = []
        for key in keys {
            let descriptor = NSSortDescriptor(key: key, ascending: ascending)
            descriptors.append(descriptor)
        }
        
        return descriptors
    }
    
    class func ascendingSortDescriptors(keys: [String]) -> [NSSortDescriptor] {
        return sortDescriptors(ascending: true, keys: keys)
    }
      
    class func descendingSortDescriptors(keys: [String]) -> [NSSortDescriptor] {
        return sortDescriptors(ascending: false, keys: keys)
    }
}

extension NSManagedObject {
    
    /// 创建新实体对象
    class func createEntity(in context: NSManagedObjectContext) -> Self {
        let entity = entityDescription(in: context)
        return Self(entity: entity!, insertInto: context)
    }
    
    class func createEntity(forEntityName name: String, in context: NSManagedObjectContext) -> Self {
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)
        return Self(entity: entity!, insertInto: context)
    }
                    
    /// 通过对象的唯一标识符在指定的上下文中获取对应的托管对象
    func inContext(otherContext: NSManagedObjectContext) -> NSManagedObject? {
        if self.objectID.isTemporaryID {
            /// 临时标识符意味着对象还没有被保存到持久存储中
            do {
                /// 将对象的临时标识符转换为永久标识符，并将其保存到对象上下文中
                try self.managedObjectContext?.obtainPermanentIDs(for: [self])
            } catch let error {
                debugPrint(error.localizedDescription)
                return nil
            }
        }

        do {
            let object = try otherContext.existingObject(with: self.objectID)
            return object
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }

    
    /// 删除实体
    func deleteEntity(in context: NSManagedObjectContext) -> Bool {
        if let object = try? context.existingObject(with: self.objectID) {
            context.delete(object)
            return true
        }
        
        return false
    }

    func deleteEntity() -> Bool {
        guard let context = managedObjectContext else {
            return false
        }
        
        return self.deleteEntity(in: context)
    }
    
    /// 删除符合条件的所有托管对象
    class func truncateAll(matchingPredicate predicate: NSPredicate,
                           in context: NSManagedObjectContext) -> Bool {
        let request = fetchAllRequest(with: predicate, in: context)
        return truncate(with: request, in: context)
    }
    
    /// 删除所有托管对象
    class func truncateAll(in context: NSManagedObjectContext) -> Bool {
        let request = fetchAllRequest(in: context)
        return truncate(with: request, in: context)
    }
    
    private class func truncate(with request: NSFetchRequest<NSFetchRequestResult>,
                                in context: NSManagedObjectContext) -> Bool {
        /// 仅返回被删除对象的ID
        request.returnsObjectsAsFaults = true
        request.includesPropertyValues = false
        guard let objectsToTruncate = executeFetchRequest(request, in: context) as? [NSManagedObject] else {
            return false
        }
        
        for objectToTruncate in objectsToTruncate {
            let _ = objectToTruncate.deleteEntity(in: context)
        }
        
        return true
    }

}
