//
//  ValueTransformerRegister.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/1.
//

import Foundation

extension ValueTransformer {

    /// 转换器注册方法
    public static func register() {
        let name = NSValueTransformerName(rawValue: String(describing: Self.self))
        let transformer = Self.init()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}

