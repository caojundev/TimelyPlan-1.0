//
//  TodoFilter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/14.
//

import Foundation
import UIKit

class TodoFilter: NSObject,
                  TPHexColorConvertible,
                  IdentifiableItem,
                  SortableIdentifiable {
    
    var identifier: String
    
    /// 名称
    var name: String?
    
    /// 颜色十六进制字符串
    var colorHex: String?
    
    /// 过滤规则
    private lazy var rule: TodoFilterRule? = {
        if let json = ruleJSON {
            return TodoFilterRule.model(with: json)
        }
        
        return nil
    }()
    
    /// 规则 JSON 字符串
    private var ruleJSON: String?
    
    /// 颜色
    private(set) lazy var color: UIColor = {
        if let colorHex = colorHex {
            return UIColor(RGBString: colorHex) ?? Self.defaultColor
        }
        
        return Self.defaultColor
    }()

    /// 编辑过滤器
    var editingFilter: TodoEditFilter {
        let color = self.color ?? TodoFilter.defaultColor
        return TodoEditFilter(name: self.name, color: color, rule: self.rule)
    }
    
    // MARK: - SortableIdentifiable
    /// 排序因子
    var order: Int64
    
    var identifiableKey: String {
        return identifier
    }
    
    /// 标签颜色数组
    static let colors: [UIColor] = [.blue(5),
                                    .red(5),
                                    .orange(5),
                                    .green(5),
                                    .purple(5),
                                    .pinkPurple(5),
                                    .cyan(5),
                                    .gray(5)]
    
    
    /// 默认颜色
    static var defaultColor: UIColor {
        return colors[0]
    }
    
    init(content: CDTodoFilter) {
        self.identifier = content.identifier ?? ""
        self.name = content.name
        self.colorHex = content.colorHex
        self.order = content.order
        self.ruleJSON = content.ruleJSON
        super.init()
    }

    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TodoFilter else { return false }
        if self === other { return true }
        return identifier == other.identifier &&
                name == other.name &&
                colorHex == other.colorHex &&
                ruleJSON == other.ruleJSON
    }

    
    override func diffIdentifier() -> NSObjectProtocol {
        return self.identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? TodoFilter else { return false }
        if self === other { return true }
        return identifier == other.identifier
    }
}
