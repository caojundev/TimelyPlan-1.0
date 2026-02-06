//
//  Array+ListDiffable.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/10.
//

import Foundation
import UIKit

extension Array where Element: ListDiffable {
    
    func indexOf(_ element: Element) -> Int? {
        for (index, item) in enumerated() {
            if item === element || item.isEqual(toDiffableObject: element) {
                return index
            }
        }
        
        return nil
    }
}
