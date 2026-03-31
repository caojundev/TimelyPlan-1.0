//
//  NSSortDescriptor+HandyRecord.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/31.
//

import Foundation

extension NSSortDescriptor {
    
    static func descriptors(with sortTerms: [SortTerm]) -> [NSSortDescriptor] {
        var sortDescriptors = [NSSortDescriptor]()
        for sortTerm in sortTerms {
            let sortDescriptor = NSSortDescriptor(key: sortTerm.key,
                                                  ascending: sortTerm.ascending)
            sortDescriptors.append(sortDescriptor)
        }
        
        return sortDescriptors
    }
}
