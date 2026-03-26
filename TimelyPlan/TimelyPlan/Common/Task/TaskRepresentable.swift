//
//  Named.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/1.
//

import Foundation

protocol TaskRepresentable {
    
    /// 获取任务特征信息
    var feature: TaskFeature { get }
}
