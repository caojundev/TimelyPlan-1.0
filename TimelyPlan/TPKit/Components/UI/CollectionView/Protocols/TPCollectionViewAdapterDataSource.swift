//
//  TPCollectionViewAdapterDataSource.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/18.
//

import Foundation

protocol TPCollectionViewAdapterDataSource: AnyObject {
    
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]?
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]?
}

extension TPCollectionViewAdapterDataSource {
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return nil
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return nil
    }
}

/// 单个区块列表数据源协议
protocol TPCollectionSingleSectionListDataSource: TPCollectionViewAdapterDataSource {
    
}

extension TPCollectionSingleSectionListDataSource {
    
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return [String(describing: type(of: self)) as NSString]
    }
    
}
