//
//  UIImage+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/26.
//

import Foundation
import UIKit

extension UIImage {
    
    static func image(named name: String, color: UIColor?) -> UIImage? {
        let image = UIImage(named: name)
        if let color = color {
            return image?.withTintColor(color, renderingMode: .alwaysOriginal)
        }
        
        return image
    }
    
}
