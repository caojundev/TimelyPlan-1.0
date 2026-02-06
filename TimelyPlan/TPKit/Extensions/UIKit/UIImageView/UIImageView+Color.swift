//
//  UIImageView+Color.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/31.
//

import Foundation

extension UIImageView {
    
    /// 更新图片渲染颜色
    func updateImage(withColor color: UIColor?) {
        guard let color = color, let image = self.image else {
            return
        }
        
        self.image = image.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
}
