//
//  TPImageAccessoryConfig.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/8.
//

import Foundation
import UIKit

class TPImageAccessoryConfig {
    
    /// 图片尺寸
    var size: CGSize = .mini
    
    /// 图片外间距
    var margins = UIEdgeInsets(right: 10.0)

    /// 是否使用颜色渲染图片
    var shouldRenderImageWithColor: Bool = true

    /// 图片渲染色
    var color: UIColor? = resGetColor(.title)
    
    /// 高亮颜色
    var highlightedColor: UIColor?
    
    /// 选中颜色
    var selectedColor: UIColor?
    
    /// 方便设置图片名称和颜色
    convenience init(color: UIColor? = nil) {
        self.init()
        self.color = color
        self.shouldRenderImageWithColor = color != nil
    }
    
    /// 方便设置图片名称、尺寸和外间距
    convenience init(size: CGSize = .mini, margins: UIEdgeInsets = UIEdgeInsets(right: 10.0)) {
        self.init()
        self.size = size
        self.margins = margins
    }
    
    /// 静态方法快速创建配置对象
    static func withColor(_ color: UIColor?) -> TPImageAccessoryConfig {
        return TPImageAccessoryConfig(color: color)
    }
    
    static func withSize(_ size: CGSize, margins: UIEdgeInsets = UIEdgeInsets(right: 10.0)) -> TPImageAccessoryConfig {
        return TPImageAccessoryConfig(size: size, margins: margins)
    }
    
    // MARK: - 链式方法
    @discardableResult
    func color(_ color: UIColor) -> Self {
        self.color = color
        return self
    }
    
    func highlightedColor(_ color: UIColor) -> Self {
        self.highlightedColor = color
        return self
    }
    
    func selectedColor(_ color: UIColor) -> Self {
        self.selectedColor = color
        return self
    }
    
    func size(_ size: CGSize) -> Self {
        self.size = size
        return self
    }
    
    func margins(_ margins: UIEdgeInsets) -> Self {
        self.margins = margins
        return self
    }
    
    func shouldRenderImageWithColor(_ shouldRenderImageWithColor: Bool) -> Self {
        self.shouldRenderImageWithColor = shouldRenderImageWithColor
        return self
    }
}
