//
//  TPPageMenuRepresentable.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/21.
//

import Foundation

protocol TPPageMenuRepresentable: AnyObject {
    
    /// 选中条目处的菜单
    func selectItem(at index: Int, animated: Bool)
    
    /// 根据当前交互拖动进度更新菜单
    func updateMenu(with progress: CGFloat)
}

extension TPPageMenuRepresentable {
    
    func updateMenu(with progress: CGFloat) {
        /// 无操作
    }
}
