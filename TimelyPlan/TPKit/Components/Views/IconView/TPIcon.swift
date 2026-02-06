//
//  TPIcon.swift
//  TimelyPlan
//
//  Created by caojun on 2023/5/26.
//

import Foundation

@objcMembers public class TPIcon: NSObject, NSCopying, Codable {
    
    // 图标样式
    enum Style: Int, Codable {
        case image /// 图片
        case text  /// 文本
    }
    
    var style: Style? {
        didSet {
            if style == .image {
                text = nil
            } else {
                name = nil
            }
        }
    }
    
    /// 图标名称
    var name: String?
    
    /// 文本
    var text: String?
    
    required override init() {
        super.init()
    }
    
    init(text: String) {
        super.init()
        self.style = .text
        self.text = text
    }
    
    init(name: String) {
        super.init()
        self.style = .image
        self.name = name
    }
    
    // MARK: - 等同性判断
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(style)
        hasher.combine(text)
        hasher.combine(name)
        return hasher.finalize()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TPIcon else { return false }
        if self === other { return true }
        let bEqual = style == other.style &&
                    name == other.name &&
                    text == other.text
        return bEqual
    }

    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = TPIcon()
        copy.style = style
        copy.name = name
        copy.text = text
        return copy
    }
}
