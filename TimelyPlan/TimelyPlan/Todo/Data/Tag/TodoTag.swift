//
//  TodoTag.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/2.
//

import Foundation
import UIKit

class TodoTag: NSObject, SortableIdentifiable, TPHexColorConvertible {
    
    var identifier: String
    
    /// 名称
    var name: String?
    
    /// 颜色十六进制字符串
    var colorHex: String?
    
    /// 颜色
    private(set) lazy var color: UIColor = {
        if let colorHex = colorHex {
            return UIColor(RGBString: colorHex) ?? Self.defaultColor
        }
        
        return Self.defaultColor
    }()
    
    /// 编辑标签
    var editingTag: TodoEditingTag {
        return TodoEditingTag(name: self.name, color: self.color)
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
    
    override init() {
        self.identifier = UUID().uuidString
        self.order = 0
        super.init()
        self.color = UIColor.random
    }
    
    init(content: CDTodoTag) {
        self.identifier = content.identifier ?? ""
        self.name = content.name
        self.colorHex = content.colorHex
        self.order = content.order
        super.init()
    }

    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(name)
        hasher.combine(colorHex)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TodoTag else { return false }
        if self === other { return true }
        return identifier == other.identifier &&
                name == other.name &&
                colorHex == other.colorHex
    }

    
    override func diffIdentifier() -> NSObjectProtocol {
        return self.identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? TodoTag else { return false }
        if self === other { return true }
        return identifier == other.identifier
    }
}
