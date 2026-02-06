//
//  UIImageView+ContentMode.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/31.
//

import Foundation
import UIKit

extension UIImageView {
    
    /// 设置图片并根据图像的尺寸来设置 contentMode
    func setImage(_ image: UIImage?) {
        self.image = image
        updateContentMode()
    }
    
    /// 根据图像的尺寸来更新 contentMode
    func updateContentMode() {
        guard let imageSize = image?.size else { return }
        if imageSize.width < bounds.width && imageSize.height < bounds.size.height {
            contentMode = .center
            return
        }
        
        let aspectRatio = imageSize.width / imageSize.height
        let viewAspectRatio = bounds.width / bounds.height
        if aspectRatio > viewAspectRatio {
            contentMode = .scaleAspectFit
        } else {
            contentMode = .scaleAspectFill
        }
    }
}


