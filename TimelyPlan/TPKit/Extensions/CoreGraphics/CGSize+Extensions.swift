//
//  CGSize+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/7.
//

import Foundation
import UIKit

extension CGSize {
    
    /// 未限制尺寸
    static var unlimited: CGSize {
        return CGSize(width: CGFloat.greatestFiniteMagnitude,
                      height: CGFloat.greatestFiniteMagnitude)
    }
    
    
    /// 长宽相同
    init (value: CGFloat) {
        self.init(width: value, height: value)
    }
    
    /// 获取较短边长度
    var shortSideLength: CGFloat {
        return min(width, height)
    }
    
    /// 获取较长边长度
    var longSideLength: CGFloat {
        return max(width, height)
    }
    
    var halfWidth: CGFloat {
        return width / 2.0
    }
    
    var halfHeight: CGFloat {
        return height / 2.0
    }
    
    /// 获取尺寸全圆角对应的圆角半径
    var roundCornerRadius: CGFloat {
        return shortSideLength / 2.0
    }
    
    /// 根据限制尺寸获取合适的尺寸
    func fitSize(with constraintSize: CGSize) -> CGSize {
        let width = min(constraintSize.width, self.width)
        let height = min(constraintSize.height, self.height)
        return CGSize(width: width, height: height)
    }
    
    func fitSize(with constraintFrame: CGRect) -> CGSize {
        return fitSize(with: constraintFrame.size)
    }
    
    /// 根据圆半径获取一个可完全放置在其内部的标签尺寸
    static func circleInnerLabelSize(radius: CGFloat) -> CGSize {
        let angle: CGFloat = 30.0
        let width = cos(angle.degreesToRadians) * radius * 2.0
        let height = radius
        return CGSize(width: width, height: height)
    }
    
    /// 计算特定约束条件下的文本尺寸
    static func boundingSize(string: Any?,
                             font: UIFont,
                             constraintWidth: CGFloat,
                             linesCount: Int = 0) -> CGSize {
        guard let string = string else {
            return .zero
        }
        
        let constraintHeight = constraintHeight(for: string, with: font, linesCount: linesCount)
        let constraintSize = CGSize(width: constraintWidth, height: constraintHeight)
        var boundingSize: CGSize = .zero
        if let string = string as? String {
            boundingSize = string.size(with: font, maxSize: constraintSize)
        } else if let attributedString = string as? NSAttributedString {
            boundingSize = attributedString.size(with: font, maxSize: constraintSize)
        } else if let attributedString = string as? ASAttributedString {
            boundingSize = attributedString.value.size(with: font, maxSize: constraintSize)
        }
        
        return CGSize(width: ceil(boundingSize.width), height: ceil(boundingSize.height))
    }
    
    static func constraintHeight(for string: Any?, with font: UIFont, linesCount: Int) -> CGFloat {
        guard linesCount > 0 else {
            return .greatestFiniteMagnitude
        }
        
        var lineHeight = font.lineHeight
        if !(string is String) {
            var attributedString: NSAttributedString?
            if let value = string as? NSAttributedString {
                attributedString = value
            } else if let value = string as? ASAttributedString {
                attributedString = value.value
            }
            
            if let attributedString = attributedString {
                let size = attributedString.size(with: font, maxSize: .unlimited)
                if size.height > lineHeight {
                    lineHeight = size.height
                }
            }
        }

        return CGFloat(linesCount) * ceil(lineHeight)
    }
}
