//
//  Checkable.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/10.
//

import Foundation

protocol Checkable: AnyObject {
    
    /// 是否选中
    var isChecked: Bool {get set}
    
    /// 动画设置选中
    func setChecked(_ checked: Bool, animated: Bool)
}
