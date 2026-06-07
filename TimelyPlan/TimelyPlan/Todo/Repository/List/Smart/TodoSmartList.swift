//
//  TodoSmartList.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/13.
//

import Foundation
import UIKit

/// 智能清单类型
enum TodoSmartListType: String, Codable, TPMenuRepresentable {
    case inbox     /// 收件箱
    case myDay     /// 我的一天
    case completed /// 已完成
    case overdue   /// 已过期
    case today     /// 今天
    case tomorrow  /// 明天
    case upcoming  /// 接下来
    case trash     /// 废纸篓
    
    /// 除废纸篓之外所有类型数组
    static var typesExceptTrash: [TodoSmartListType] {
        var types = TodoSmartListType.allCases
        let _ = types.remove(.trash)
        return types
    }
    
    static var scheduleTypes: [TodoSmartListType] {
        return [.overdue, .today, .tomorrow, .upcoming]
    }
    
    var isScheduleType: Bool {
        return Self.scheduleTypes.contains(self)
    }
    
    var title: String {
        if self == .myDay {
            return resGetString("My Day")
        } else {
            return defaultTitle
        }
    }
    
    /// 图标名称
    var iconName: String? {
        if self == .today {
            return "calendar_\(Date().day)_24"
        }
        
        return "todo_smartlist_" + self.rawValue + "_24"
    }
}

class TodoSmartList: NSObject,
                     TodoListRepresentable,
                     IdentifiableItem {
    
    var identifier: String
    
    var iconName: String? {
        return listType.iconName
    }
    
    var title: String {
        return listType.title
    }
    
    var color: UIColor {
        switch listType {
        case .myDay:
            return .primary4
        case .inbox:
            return Color(0x237DFF)
        case .completed:
            return Color(0x3DC862)
        case .overdue:
            return .red(5)
        case .today:
            return Color(0x2D96FF)
        case .tomorrow:
            return .orange(5)
        case .upcoming:
            return Color(0x7E68FF)
        case .trash:
            return Color(0xE64433)
        }
    }
    
    var icon: UIImage? {
        if let iconName = listType.iconName {
            return resGetImage(iconName)
        }
        
        return nil
    }
    
    var feature: TodoListFeature {
        return TodoListFeature(identifier: identifier,
                               emoji: nil,
                               name: listType.title,
                               colorHex: color.hexString,
                               layoutRawValue: -1)
    }
    
    /// 列表类型
    let listType: TodoSmartListType
    
    init(type: TodoSmartListType) {
        self.listType = type
        self.identifier = type.rawValue
        super.init()
    }
    
    static var inbox: TodoSmartList {
        return TodoSmartList(type: .inbox)
    }
    
    static var myDay: TodoSmartList {
        return TodoSmartList(type: .myDay)
    }
    
    static var completed: TodoSmartList {
        return TodoSmartList(type: .completed)
    }
    
    static var overdue: TodoSmartList {
        return TodoSmartList(type: .overdue)
    }
    
    static var today: TodoSmartList {
        return TodoSmartList(type: .today)
    }
    
    static var tomorrow: TodoSmartList {
        return TodoSmartList(type: .tomorrow)
    }
    
    static var upcoming: TodoSmartList {
        return TodoSmartList(type: .upcoming)
    }
    
    static var trash: TodoSmartList {
        return TodoSmartList(type: .trash)
    }
    
    /// 获取所有智能清单对象
    static var allLists: [TodoSmartList] {
         return TodoSmartListType.allCases.map {
             TodoSmartList(type: $0)
         }
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(listType)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TodoSmartList else { return false }
        if self === other { return true }
        return listType == other.listType
    }
    
    // MARK: - Equatable
    static func == (lhs: TodoSmartList, rhs: TodoSmartList) -> Bool {
        return lhs.listType == rhs.listType
    }
        
    override func diffIdentifier() -> NSObjectProtocol {
        return self.identifier as NSString
    }
}
