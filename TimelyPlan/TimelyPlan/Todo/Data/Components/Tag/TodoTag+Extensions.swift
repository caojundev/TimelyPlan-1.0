//
//  TodoTag.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/3.
//

import Foundation

extension TodoTag: Sortable,
                    TPHexColorConvertible {

    /// 编辑标签
    var editTag: TodoEditTag {
        return TodoEditTag(name: name, color: (color ?? TodoTag.defaultColor))
    }
    
    /// 标签富文本信息
    func attributedInfo() -> ASAttributedString? {
        if let name = self.name, name.count > 0 {
            let color = self.color ?? Self.defaultColor
            return "\("●", .foreground(color)) \(name)"
        }

        return nil
    }
    
    /// 更新标签
    func update(with editTag: TodoEditTag) {
        name = editTag.name
        colorHex = editTag.color.hexString
    }
}

extension TodoTag {
    /// 默认颜色
    static let defaultColor = colors[0]
    
    /// 标签颜色数组
    static let colors: [UIColor] = [.blue(5),
                                    .red(5),
                                    .orange(5),
                                    .green(5),
                                    .purple(5),
                                    .pinkPurple(5),
                                    .cyan(5),
                                    .gray(5)]
    
    /// 新建列表
    static func newTag(with editTag: TodoEditTag, order: Int64 = 0) -> TodoTag {
        let tag = TodoTag.createEntity(in: .defaultContext)
        tag.identifier = NSUUID().uuidString
        tag.order = order
        tag.creationDate = .now
        tag.update(with: editTag)
        return tag
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
