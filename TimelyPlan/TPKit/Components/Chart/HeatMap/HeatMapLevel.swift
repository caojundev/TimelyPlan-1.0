//
//  HeatMapLevel.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/1.
//

import Foundation
import UIKit

let kHeatMapNoneColor = Color(0x888888, 0.1)
let kHeatMapLevelColor = Color(0x66D065)

struct HeatMapLevel {
    
    /// 分级颜色
    var color: UIColor
    
    /// 描述信息
    var info: String?
}

class HeatMapInfo {
    
    /// 分级
    var levels: [HeatMapLevel]

    /// 图标画布尺寸
    var iconCanvasSize: CGSize = CGSize(width: 18.0, height: 18.0)
    
    /// 图标尺寸
    var iconSize: CGSize = CGSize(width: 16.0, height: 16.0)
    
    /// 默认图标圆角半径
    var iconRadius: CGFloat = 4.0
    
    /// 头文本
    var leadingText: String?
    
    /// 尾文本
    var trailingText: String?
    
    /// 分隔符，默认为一个空格
    var separator: String = " "
    
    init(levels: [HeatMapLevel]) {
        self.levels = levels
    }
    
    var attributedInfo: ASAttributedString {
        var levelStrings: [ASAttributedString] = []
        for level in levels {
            if let image = UIImage.image(color: level.color,
                                         size: iconSize,
                                         canvasSize: iconCanvasSize,
                                         cornerRadius: iconRadius) {
                let levelString: ASAttributedString = .string(with: image, trailingText: level.info)
                levelStrings.append(levelString)
            }
        }
        
        var info = levelStrings.joined(separator: separator)
        if let leadingText = leadingText {
            info = leadingText + " " + info
        }
        
        if let trailingText = trailingText {
            info = info + " " + trailingText
        }
        
        return info
    }
}
