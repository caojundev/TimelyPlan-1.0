//
//  TodoTaskEditTableCellItem.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/13.
//

import Foundation
import UIKit

class TodoTaskEditTableCellItem: TPImageInfoRightButtonTableCellItem {
    
    /// 是否为活动状态
    var isActive: Bool = false {
        didSet {
            updateConfig()
        }
    }
    
    var normalColor: UIColor = resGetColor(.title)
    
    var activeColor: UIColor = .primary
    
    override var rightViewSize: CGSize {
        get {
            return isActive ? .mini : .zero
        }
        
        set {}
    }
    
    override var isRightButtonHidden: Bool {
        get {
            return isActive ? false : true
        }
        
        set {}
    }
    
    override init() {
        super.init()
        self.rightButtonImageName = "xmark_12"
        self.subtitleConfig.font = UIFont.boldSystemFont(ofSize: 10.0)
    }
    
    /// 更新配置
    func updateConfig() {
        if isActive {
            imageConfig.color = activeColor
            titleConfig.textColor = activeColor
            subtitleConfig.textColor = activeColor
        } else {
            imageConfig.color = normalColor
            titleConfig.textColor = normalColor
            subtitleConfig.textColor = normalColor
        }
    }
}
