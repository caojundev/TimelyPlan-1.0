//
//  CALayer+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/14.
//

import Foundation
import UIKit

extension CALayer {
    func setLayerShadow(color: UIColor, offset: CGSize, radius: CGFloat) {
        self.shadowColor = color.cgColor
        self.shadowOffset = offset
        self.shadowRadius = radius
        self.shadowOpacity = 1
        self.shouldRasterize = true
        self.rasterizationScale = UIScreen.main.scale
    }

    func setLayerShadow(path: CGPath, color: UIColor, offset: CGSize, radius: CGFloat) {
        self.shadowPath = path
        setLayerShadow(color: color, offset: offset, radius: radius)
    }

    func setBorderShadow(color: UIColor = .shadow,
                         offset: CGSize = .zero,
                         radius: CGFloat) {
        let borderPath = UIBezierPath(rect: self.bounds)
        setLayerShadow(path: borderPath.cgPath, color: color, offset: offset, radius: radius)
    }

    func setBorderShadow(color: UIColor,
                         offset: CGSize,
                         radius: CGFloat,
                         roundCorners corners: UIRectCorner,
                         cornerRadius: CGFloat) {
        let borderPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        setLayerShadow(path: borderPath.cgPath, color: color, offset: offset, radius: radius)
    }

    func removeShadow() {
        self.shadowPath = nil
        self.shadowColor = UIColor.clear.cgColor
        self.shadowOffset = .zero
        self.shadowRadius = 0
    }
}
