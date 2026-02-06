//
//  NSPersistentStore+HandyRecord.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/10.
//

import Foundation
import CoreData

fileprivate var HandyRecordDefaultPersistentStore: NSPersistentStore?

extension NSPersistentStore {
    
    class var defaultPersistentStore: NSPersistentStore? {
        get {
            return HandyRecordDefaultPersistentStore
        }
        
        set {
            HandyRecordDefaultPersistentStore = newValue
        }
    }
    
    class func cloudURL(forUbiquityContainerIdentifier containerIdentifier: String) -> URL? {
        let fileManager = FileManager.init()
        let url = fileManager.url(forUbiquityContainerIdentifier: containerIdentifier)
        return url
    }
    
    /*
    + (NSString *) MR_directory:(NSSearchPathDirectory)type
    {
        return [NSSearchPathForDirectoriesInDomains(type, NSUserDomainMask, YES) lastObject];
    }

    + (NSString *)MR_applicationDocumentsDirectory
    {
        return [self MR_directory:NSDocumentDirectory];
    }

    + (NSString *)MR_applicationStorageDirectory
    {
        NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
        return [[self MR_directory:NSApplicationSupportDirectory] stringByAppendingPathComponent:applicationName];
    }

    + (NSURL *) MR_urlForStoreName:(NSString *)storeFileName
    {
        NSString *pathForStoreName = [[self MR_applicationStorageDirectory] stringByAppendingPathComponent:storeFileName];
        return [NSURL fileURLWithPath:pathForStoreName];
    }

    + (NSURL *) MR_defaultLocalStoreUrl
    {
        return [self MR_urlForStoreName:kMagicalRecordDefaultStoreFileName];
    }
     */

}
