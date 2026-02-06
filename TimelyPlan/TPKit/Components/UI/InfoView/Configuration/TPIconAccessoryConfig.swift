//
//  TPIconAccessoryConfig.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/8.
//

import Foundation
import UIKit

class TPIconAccessoryConfig {
    
    /// 图标
    var icon: TPIcon?

    /// 图标尺寸
    var size: CGSize = .default
    
    /// 图标外间距
    var margins: UIEdgeInsets = .zero
    
    /// 图标颜色
    var foreColor: UIColor?
    
    var backColor: UIColor? = .clear
    
    var placeholderImage: UIImage?
}
