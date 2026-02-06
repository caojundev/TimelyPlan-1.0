//
//  TodoFilter+Extension.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/16.
//

import Foundation
import UIKit

extension TodoFilter: Sortable,
                      TPHexColorConvertible {
    
    /// 标签颜色数组
    static let colors: [UIColor] = [.blue(5),
                                    .red(5),
                                    .orange(5),
                                    .green(5),
                                    .purple(5),
                                    .pinkPurple(5),
                                    .cyan(5),
                                    .gray(5)]
    
    static var defaultColor: UIColor {
        return colors[0]
    }
    
    /// 新建过滤器
    static func newFilter(with editFilter: TodoEditFilter, order: Int64 = 0) -> TodoFilter {
        let filter = TodoFilter.createEntity(in: .defaultContext)
        filter.identifier = NSUUID().uuidString
        filter.order = order
        filter.update(with: editFilter)
        return filter
    }

    /// 更新过滤器
    func update(with editFilter: TodoEditFilter) {
        name = editFilter.name
        colorHex = editFilter.color.hexString
        rule = editFilter.rule
    }
    
    /// 编辑过滤器
    var editFilter: TodoEditFilter {
        let editColor = color ?? TodoFilter.defaultColor
        return TodoEditFilter(name: name, color: editColor, rule: rule)
    }
    
}
