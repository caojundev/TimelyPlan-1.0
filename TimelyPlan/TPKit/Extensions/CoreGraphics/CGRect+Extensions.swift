//
//  CGRect+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/17.
//

import Foundation

extension CGRect {
    
    init (size: CGSize) {
        self.init(x: 0, y: 0, width: size.width, height: size.height)
    }
    
    init (x: CGFloat, y: CGFloat, size: CGSize) {
        self.init(x: x, y: y, width: size.width, height: size.height)
    }
    
    ///  获取区域中心点坐标（相对该区域所在的区域）
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
    /// 获取区域中心点（相对于origin）
    var middlePoint: CGPoint {
        return CGPoint(x: width / 2.0, y: height / 2.0)
    }
    
    /// 获取较短边长度
    var shortSideLength: CGFloat {
        return min(width, height)
    }
    
    /// 获取较长边长度
    var longSideLength: CGFloat {
        return max(width, height)
    }
    
    /// 该区域覆盖最大圆圆角半径
    var boundingCornerRadius: CGFloat {
        return shortSideLength / 2.0
    }
    
    /// 居中圆形区域
    var middleCircleRect: CGRect {
        let length = shortSideLength
        let x = (self.width - length) / 2.0
        let y = (self.height - length) / 2.0
        return CGRect(x: self.minX + x, y: self.minY + y, width: length, height: length)
    }
    
    /// 该区域居中圆覆盖的方形区域
    var middleCircleInnerSquareRect: CGRect {
        let middleCircleRect = self.middleCircleRect
        let r = middleCircleRect.width / 2.0
        let length = sqrt(2.0) * r
        let x = (self.width - length) / 2.0
        let y = (self.height - length) / 2.0
        return CGRect(x: self.minX + x, y: self.minY + y, width: length, height: length)
    }
    
    // MARK: - 获取点坐标
    var topLeft: CGPoint {
       return CGPoint(x: minX, y: minY)
    }
    
    var topMid: CGPoint {
        return CGPoint(x: midX, y: minY)
    }
    
    var topRight: CGPoint {
       return CGPoint(x: maxX, y: minY)
    }
    
    var bottomLeft: CGPoint {
       return CGPoint(x: minX, y: maxY)
    }

    var bottomMid: CGPoint {
       return CGPoint(x: midX, y: maxY)
    }

    var bottomRight: CGPoint {
       return CGPoint(x: maxX, y: maxY)
    }
    
    var leftMid: CGPoint {
       return CGPoint(x: minX, y: midY)
    }

    var rightMid: CGPoint {
       return CGPoint(x: maxX, y: midY)
    }
}
