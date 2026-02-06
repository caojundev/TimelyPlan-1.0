//
//  CoreGraphicsFunctions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/22.
//

/// 角度转换为弧度
func radians(of degrees: CGFloat) -> CGFloat {
    return degrees * .pi / 180.0
}

/// angle转换成0～360度
func angleBetween0And2PI(_ angle: CGFloat) -> CGFloat {
    var angle = angle
    if angle < 0 {
        angle += CGFloat(((Int)(-angle / 360) + 1) * 360)
    } else if angle > 360 {
        angle -= CGFloat(((Int)(angle / 360)) * 360)
    }
    
    return angle
}

/// 获取圆上一点的坐标
func pointAtCircle(center: CGPoint, radius: CGFloat, angle: CGFloat) -> CGPoint {
    let angle = angleBetween0And2PI(angle)
    let dx = radius * cos(radians(of: angle))
    let dy = radius * sin(radians(of: angle))
    return CGPoint(x: center.x + dx, y: center.y + dy)
}
