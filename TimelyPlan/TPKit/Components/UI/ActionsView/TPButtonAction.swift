//
//  TPButtonAction.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/23.
//

import Foundation
import UIKit

enum TPButtonActionType: Int {
    case normal
    case cancel
    case destructive
}

class TPButtonAction: NSObject {
    
    /// 唯一标识
    var identifier: String = UUID().uuidString

    /// 标签
    var tag: Int = 0
    
    /// 样式
    var type: TPButtonActionType = .normal
    
    /// 标题
    var title: String?
    
    var titleFont = BOLD_SYSTEM_FONT
    
    /// 标题对齐样式
    var textAlignment: NSTextAlignment = .center
    
    /// 标题颜色
    var titleColor: UIColor? = .white.withAlphaComponent(0.8)
    
    var highlightedTitleColor: UIColor? = .white.withAlphaComponent(0.6)

    /// 标题颜色
    var imageColor: UIColor? = .white.withAlphaComponent(0.8)
    
    var highlightedImageColor: UIColor? = .white.withAlphaComponent(0.6)
    
    /// 图标
    var image: UIImage?
    
    /// 图标位置
    var imagePosition: TPAccessoryPosition = .left
    
    /// 内容内间距
    var padding: UIEdgeInsets = UIEdgeInsets(horizontal: 8.0)
    
    /// 是否可用
    @objc dynamic var isEnabled: Bool = true
    
    /// 动作回调
    var handler: ((TPButtonAction) -> Void)?
    
    /// 样式
    var style = TPCollectionCellStyle()
    
    convenience init(title: String?, backgroundColor: UIColor, handler: ((TPButtonAction) -> Void)?) {
        self.init(type: .normal, title: title, handler: handler)
        self.style.backgroundColor = backgroundColor
        self.style.selectedBackgroundColor = backgroundColor.darkerColor
    }
    
    init(type: TPButtonActionType = .normal, title: String? = nil, handler: ((TPButtonAction) -> Void)? = nil) {
        super.init()
        self.type = type
        self.title = title
        self.handler = handler
        switch type {
        case .normal:
            style.backgroundColor = .primary
        case .cancel:
            titleColor = .secondaryLabel
            highlightedTitleColor = .secondaryLabel.withAlphaComponent(0.8)
            imageColor = titleColor
            highlightedImageColor = highlightedTitleColor
            style.backgroundColor = .secondarySystemFill
            style.selectedBackgroundColor = .secondarySystemFill
        case .destructive:
            style.backgroundColor = .danger6
        }
        
        style.cornerRadius = 12.0
    }
}
