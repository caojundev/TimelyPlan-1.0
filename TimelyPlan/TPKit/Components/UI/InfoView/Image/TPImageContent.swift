//
//  TPImageContent.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/11.
//

import Foundation
import UIKit

class TPImageContent: Equatable {
    
    /// 获取图片
    var image: UIImage? {
        if let value = value as? UIImage {
            return value
        } else if let value = value as? String {
            return resGetImage(value)
        }
        
        return nil
    }
    
    var name: String? {
        return value as? String
    }
    
    private(set) var value: Any?
    
    convenience init(imageName: String?) {
        self.init()
        self.value = imageName
    }
    
    convenience init(image: UIImage?) {
        self.init()
        self.value = image
    }
    
    static func withName(_ imageName: String?) -> TPImageContent {
        return TPImageContent(imageName: imageName)
    }

    static func withImage(_ image: UIImage?) -> TPImageContent {
        return TPImageContent(image: image)
    }

    // MARK: - Equatable
    static func == (lhs: TPImageContent, rhs: TPImageContent) -> Bool {
        return lhs.image == rhs.image
    }
    
    /// 计算实际使用的图片尺寸
    func fitSize(with config: TPImageAccessoryConfig) -> CGSize {
        return value != nil ? config.size : .zero
    }
    
    /// 计算实际使用的图片外间距
    func fitMargins(with config: TPImageAccessoryConfig) -> UIEdgeInsets {
        return value != nil ? config.margins : .zero
    }
    
}
