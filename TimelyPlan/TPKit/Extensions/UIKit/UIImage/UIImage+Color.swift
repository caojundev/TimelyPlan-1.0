//
//  UIImage+Color.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/1.
//

import Foundation

extension UIImage {

    class func image(color: UIColor,
                     size: CGSize,
                     canvasSize: CGSize?,
                     cornerRadius radius: CGFloat) -> UIImage? {
        
        let canvasSize = canvasSize ?? size
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        
        let x = (canvasSize.width - size.width) / 2.0
        let y = (canvasSize.height - size.height) / 2.0
        let image = renderer.image { context in
            let rect = CGRect(origin: CGPoint(x: x, y: y), size: size)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
            color.setFill()
            path.fill()
        }
        
        return image
    }
}
