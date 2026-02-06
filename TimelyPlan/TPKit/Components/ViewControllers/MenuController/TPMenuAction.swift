//
//  TPMenuAction.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/17.
//

import Foundation
import UIKit

enum TPMenuActionStyle: Int {
    case normal /// 默认
    case destructive /// 删除样式
    case custom /// 自定义颜色
}

class TPMenuAction: NSObject {
    
    /// 菜单动作标识
    var identifier: String = UUID().uuidString

    /// 标签
    var tag: Int = 0
    
    /// 菜单标题
    var title: String?
    
    /// 副标题
    var subtitle: String?
    
    /// 值文本
    var valueText: String?
    
    /// 菜单图标
    var image: UIImage?
    
    /// 是否选中
    var isChecked: Bool = false
    
    /// 在视图控制器dismiss前调用菜单回调
    var handleBeforeDismiss: Bool = false
    
    /// 菜单处理回调
    var handler: ((TPMenuAction) -> Void)?
    
    /// 样式
    var style: TPMenuActionStyle = .normal

    /// 标题颜色
    var titleColor: UIColor? {
        get {
            switch style {
            case .normal:
                return Self.normalColor
            case .destructive:
                return Self.destructiveColor
            case .custom:
               return _titleColor
            }
        }
        
        set {
            _titleColor = newValue
        }
    }
    
    /// 图片颜色
    var iconColor: UIColor? {
        get {
            switch style {
            case .normal:
                return Self.normalColor
            case .destructive:
                return Self.destructiveColor
            case .custom:
               return _iconColor
            }
        }
        
        set {
            _iconColor = newValue
        }
    }

    private var _titleColor: UIColor? = TPMenuAction.normalColor
    private var _iconColor: UIColor? = TPMenuAction.normalColor
 
    static var normalColor = resGetColor(.title)
    static var destructiveColor = Color(0xE2183E)
}

extension TPMenuAction {
    
    func actionType<T: TPMenuRepresentable>() -> T? where T.RawValue == Int {
        return T(rawValue: tag)
    }
    
    func actionType<T: TPMenuRepresentable>() -> T? where T.RawValue == String {
        return T(rawValue: identifier)
    }
    
    
    // MARK: - ListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}



