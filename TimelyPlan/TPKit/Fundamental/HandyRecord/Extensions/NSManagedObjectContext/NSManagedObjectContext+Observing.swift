//
//  NSManagedObjectContext+Observing.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/10.
//

import Foundation
import CoreData

let kHandyRecordDidMergeChangesFromICloudNotification = Notification.Name(rawValue: "HandyRecordDidMergeChangesFromICloudNotification")

extension NSManagedObjectContext {
    
    // MARK: - Context Observation Helpers
    func observeContextOnMainThread(_ otherContext: NSManagedObjectContext) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mergeChangesOnMainThread(fromObjectsDidSave:)),
                                               name: Self.didSaveObjectsNotification,
                                               object: otherContext)
    }
    
    func observeContext(_ otherContext: NSManagedObjectContext) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mergeChanges(fromObjectsDidSave:)),
                                               name: Self.didSaveObjectsNotification,
                                               object: otherContext)
    }
    
    func stopObservingContext(_ otherContext: NSManagedObjectContext) {
        NotificationCenter.default.removeObserver(self,
                                                  name: Self.didSaveObjectsNotification,
                                                  object: otherContext)
    }
    
    // MARK: - Merge Changes
    @objc func mergeChanges(fromObjectsDidSave notification: Notification) {
        debugPrint("Merging changes to %@context%@",
              (self == Self.defaultContext) ? "*** DEFAULT *** " : "",
                   (Thread.isMainThread ? " *** on Main Thread ***" : ""));
        mergeChanges(fromContextDidSave: notification)
    }
    
    @objc func mergeChangesOnMainThread(fromObjectsDidSave notification: Notification) {
        if Thread.isMainThread {
            mergeChanges(fromObjectsDidSave: notification)
        } else {
            /// 调用线程需要一直等待任务合并完成
            performSelector(onMainThread: #selector(mergeChanges(fromObjectsDidSave:)),
                            with: notification,
                            waitUntilDone: true)
        }
    }
}
 

// iCloud
extension NSManagedObjectContext {
    // MARK: - iCloud
    func observeICloudChanges(inCoordinator coordinator: NSPersistentStoreCoordinator) {
        guard HandyRecord.isICloudEnabled else {
            return
        }
    
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mergeChanges(fromIClound:)),
                                               name: NSNotification.Name.NSPersistentStoreRemoteChange,
                                               object: coordinator)
    }

    func stopObservingICloudChanges(inCoordinator coordinator: NSPersistentStoreCoordinator) {
        guard HandyRecord.isICloudEnabled else {
            return
        }
 
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.NSPersistentStoreRemoteChange,
                                                  object: coordinator)
    }

    @objc func mergeChanges(fromIClound notification: Notification) {
        perform {
//            debugPrint("Merging changes From iCloud",
//                       self == Self.defaultContext ? "*** DEFAULT *** " : "",
//                       (Thread.isMainThread ? " *** on Main Thread ***" : ""))
            self.mergeChanges(fromContextDidSave: notification)
            NotificationCenter.default.post(name: kHandyRecordDidMergeChangesFromICloudNotification,
                                            object: self,
                                            userInfo: notification.userInfo)
        }
    }

}
