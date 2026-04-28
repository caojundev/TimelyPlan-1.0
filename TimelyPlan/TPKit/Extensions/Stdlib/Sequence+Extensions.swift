//
//  Sequence+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/28.
//

import Foundation

extension Sequence {
    func anySatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        return try contains(where: predicate)
    }
}
