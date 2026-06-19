//
//  TodoTag.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/2.
//

import Foundation
import UIKit

class TodoTag: NSObject,
               TPHexColorConvertible,
               IdentifiableItem,
               SortableIdentifiable {
    
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
    
    init?(content: CDTodoTag) {
        guard let identifier = content.identifier else {
            return nil
        }
        
        self.identifier = identifier
        self.name = content.name
        self.colorHex = content.colorHex
        self.order = content.order
        super.init()
    }
    
    func update(with editingTag: TodoEditingTag) {
        self.name = editingTag.name
        self.colorHex = editingTag.color.hexString
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
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

extension Array where Element == TodoTag {
    
    /// 获取组合的标签富文本字符串
    func attributedInfo(separator: String = ", ") -> ASAttributedString? {
        var strings = [ASAttributedString]()
        for tag in self {
            if let name = tag.name, name.count > 0, let color = tag.color {
                let string: ASAttributedString = "\("●", .foreground(color)) \(name)"
                strings.append(string)
            }
        }

        return strings.joined(separator: ", ")
    }
}

extension Set where Element == TodoTag {
    
    func attributedOrderedTagsInfo(separator: String = ", ") -> ASAttributedString? {
        guard self.count > 0 else {
            return nil
        }

        return orderedElements().attributedInfo(separator: separator)
    }
}
