//
//  Array+Chart.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/5.
//

import Foundation

extension Array where Element: UIView {
    
    /// 找到视图在垂直方向到某一点距离最小的视图
    func verticalClosestView(to point: CGPoint) -> Element? {
        guard self.count > 1 else {
            return self.first
        }
        
        var minDistance = CGFloat.greatestFiniteMagnitude
        var closestView: Element?
        for view in self {
            let center = CGPoint(x: point.x, y: view.centerY)
            var distance = sqrt(pow(center.x - point.x, 2) + pow(center.y - point.y, 2))
            distance -= view.height / 2.0
            if distance < minDistance {
                minDistance = distance
                closestView = view
            }
        }
        
        return closestView
    }
}
