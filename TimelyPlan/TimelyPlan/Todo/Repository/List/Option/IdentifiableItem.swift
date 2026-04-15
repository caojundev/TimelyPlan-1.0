//
//  IdentifiableItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/15.
//

import Foundation

protocol IdentifiableItem: AnyObject {
    var identifier: String {get set}
}
