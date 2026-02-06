//
//  PieLineDrawer.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/10.
//

import Foundation

class PieLineDrawer {
    
    var radius: CGFloat = 160.0
    
    var margin: CGFloat = 4.0
    
    var length: CGFloat = 10.0
    
    func lineQuadCurve(rect: CGRect, angle: PieSliceAngle) -> (start: CGPoint,
                                                               end: CGPoint,
                                                               control: CGPoint) {
        /// 圆心
        let circleCenter = rect.middlePoint
    
        /// 起始点
        let startTranslation = angle.getTranslation(newRadius: radius + margin)
        let startPoint = CGPoint(
            x: circleCenter.x + startTranslation.width,
            y: circleCenter.y + startTranslation.height
        )
        
        // 控制点
        let controlTranslation = angle.getTranslation(newRadius: radius + margin + length)
        let controlPoint = CGPoint(
            x: circleCenter.x + controlTranslation.width,
            y: circleCenter.y + controlTranslation.height
        )
        
        // 结束点
        let endOffsetX: CGFloat = controlTranslation.width > 0 ? length : -length
        let endPoint = CGPoint(
            x: controlPoint.x + endOffsetX,
            y: controlPoint.y
        )
        
        return (startPoint, endPoint, controlPoint)
    }
    
}

