//
//  TPTableViewAdapterDataSource.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/27.
//

import Foundation

protocol TPTableViewAdapterDataSource: AnyObject {
    
    func sectionObjects(for adapter: TPTableViewAdapter) -> [ListDiffable]?
    
    func adapter(_ adapter: TPTableViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]?
}

extension TPTableViewAdapterDataSource {
    
    func sectionObjects(for adapter: TPTableViewAdapter) -> [ListDiffable]? {
        return nil
    }
    
    func adapter(_ adapter: TPTableViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return nil
    }
}
