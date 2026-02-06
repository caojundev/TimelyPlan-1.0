//
//  HandyRecord+Setup.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/10.
//

import Foundation
import CoreData

/// 容器名称
fileprivate let kContainerName = "TimelyPlan"
let kUbiquityContainerIdentifier = "iCloud.com.caojun.TimelyPlan"

extension HandyRecord {
    
    /// 本地存储
    
    /// CloudKit
    
    /// 初始化持久容器
    static func setup(completion: @escaping (Bool) -> Void){
        setupContainer(name: kContainerName) { container in
            guard let container = container else {
                completion(false)
                return
            }

            /// 初始化上下文
            let coordinator = container.persistentStoreCoordinator
            NSPersistentStoreCoordinator.defaultStoreCoordinator = coordinator
            NSManagedObjectContext.initialize(withContainer: container)
            completion(true)
        }
    }
    
    /// 根据名称初始化持久容器
    /// - Parameters:
    ///   - name: 名称
    ///   - completion: 持久容器初始化完成回调
    private static func setupContainer(name: String, completion: @escaping(NSPersistentContainer?) -> ()) {
        let container = NSPersistentCloudKitContainer(name: name)
        guard let description = container.persistentStoreDescriptions.first else {
               NSLog("Unable to retrieve persistent store description.")
               return
        }
        
        let storeURL = getStoreURL(name,
                                   containerID: kUbiquityContainerIdentifier,
                                   cloudStorePathComponent: nil)
        description.setOption(storeURL as NSURL, forKey: NSPersistentStoreURLKey)
        description.setOption(NSNumber(value: true),
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        container.loadPersistentStores { _, error in
            guard error == nil else {
                debugPrint(error.debugDescription)
                fatalError("Failed to load persistentStore:\(error!.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                completion(container)
            }
        }
    }
    
    static func getStoreURL(_ storeIdentifier: String,
                     containerID: String,
                     cloudStorePathComponent: String?) -> URL {
        var storeURL: URL
        let storeName = "\(storeIdentifier).sqlite"
        let fileManager = FileManager.default
        if let baseURL = FileManager.default.url(forUbiquityContainerIdentifier: containerID) {
            var cloudURL = baseURL
            if let subPathComponent = cloudStorePathComponent {
                cloudURL.appendPathComponent(subPathComponent)
            }
            
            storeURL = cloudURL.appendingPathComponent(storeName)
        } else {
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            storeURL = documentsDirectory.appendingPathComponent(storeName)
        }
        
        return storeURL
    }
}
