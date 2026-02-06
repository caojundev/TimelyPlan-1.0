//
//  CaseIterable+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/23.
//

import Foundation

extension CaseIterable where Self: Equatable {
    
    /// 获取 case 对应索引
    var index: Int? {
        let index = Self.allCases.firstIndex(of: self)
        return  index as? Int
    }
}

extension CaseIterable where Self: RawRepresentable {
    
    /// 获取所有rawValue数组
    static var allRawValues: [Self.RawValue] {
        return Self.allCases.map { $0.rawValue }
    }
}
