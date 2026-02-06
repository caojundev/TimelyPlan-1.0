//
//  UIBezierPath+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/21.
//

import Foundation

extension UIBezierPath {
    
    /// 添加一个矩形区域
    func addRect(_ rect: CGRect) {
        move(to: CGPoint(x: rect.minX, y: rect.minY))
        addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    }
}
