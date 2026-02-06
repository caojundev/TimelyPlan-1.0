//
//  TPSegmentedMenuItem.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/2.
//

import Foundation

enum TPSegmentedMenuStyle {
    case iconAndTitle
    case title
    case icon
}

class TPSegmentedMenuItem: NSObject {
    
    /// 标识
    lazy var identifier: String = {
       return UUID().uuidString
    }()

    /// 菜单整数标签
    var tag: Int = 0

    /// 图标名称
    var iconName: String?

    /// 标题
    var title: String?
    
    /// 副标题
    var subtitle: String?
}

extension TPSegmentedMenuItem {
    
    func actionType<T: TPMenuRepresentable>() -> T? where T.RawValue == Int {
        return T(rawValue: tag)
    }
    
    func actionType<T: TPMenuRepresentable>() -> T? where T.RawValue == String {
        return T(rawValue: identifier)
    }
    
    class func items<T: TPMenuRepresentable>(with types: [T],
                                             style: TPSegmentedMenuStyle = .title) -> [TPSegmentedMenuItem] {
        var menuItems = [TPSegmentedMenuItem]()
        for type in types {
            let menuItem = TPSegmentedMenuItem()
            menuItem.tag = type.tag
            menuItem.identifier = type.identifier
            if style == .title || style == .iconAndTitle {
                menuItem.title = type.title
            }
            
            if style == .icon || style == .iconAndTitle {
                menuItem.iconName = type.iconName
            }
            
            menuItems.append(menuItem)
        }
        
        return menuItems
    }
}

extension RawRepresentable where Self: TPMenuRepresentable {
    
    static func segmentedMenuItems(style: TPSegmentedMenuStyle = .iconAndTitle) -> [TPSegmentedMenuItem] {
        let types = Self.allCases as! [Self]
        let items = TPSegmentedMenuItem.items(with: types, style: style)
        return items
    }
}

extension Array where Element: TPMenuRepresentable {
    
    func segmentedMenuItems(style: TPSegmentedMenuStyle = .iconAndTitle) -> [TPSegmentedMenuItem] {
        return TPSegmentedMenuItem.items(with: self, style: style)
    }
}
