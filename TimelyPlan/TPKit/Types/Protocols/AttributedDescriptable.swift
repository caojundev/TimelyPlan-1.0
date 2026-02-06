//
//  AttributedDescriptable.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/7.
//

import Foundation

protocol AttributedDescriptable {
    
    /// 高亮文本颜色
    var highlightedTextColor: ASAttributedString.Attribute { get }
    
    /// 根据语言范围本地化描述文本
    func localizedAttributedDescription() -> ASAttributedString?
    
    /// 中文描述
    func cnAttributedDescription() -> ASAttributedString?
        
    /// 英文描述
    func enAttributedDescription() -> ASAttributedString?
}

extension AttributedDescriptable {
    
    var highlightedTextColor: ASAttributedString.Attribute {
        return .foreground(.primary)
    }
    
    func localizedAttributedDescription() -> ASAttributedString? {
        if Language.isChinese {
            return cnAttributedDescription()
        } else {
            return enAttributedDescription()
        }
    }
    
    /// 英文描述
    func enAttributedDescription() -> ASAttributedString? {
        return nil
    }
    
    /// 中文描述
    func cnAttributedDescription() -> ASAttributedString? {
        return enAttributedDescription()
    }
}
