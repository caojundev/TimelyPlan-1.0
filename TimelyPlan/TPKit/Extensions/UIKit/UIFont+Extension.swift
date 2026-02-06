//
//  UIFont+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/4.
//

import Foundation
import UIKit

extension UIFont {
    
    func withBold() -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) else {
            return self
        }
        
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    func withItalic() -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(.traitItalic) else {
            return self
        }
        
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    func withBoldItalic() -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) else {
            return self
        }
        
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    /// RobotoMono-Bold 字体
    static func robotoMonoBoldFont(size: CGFloat) -> UIFont? {
        return UIFont(name: "RobotoMono-Bold", size: size)
    }
    
    static func barlowCondensedFont(size: CGFloat) -> UIFont? {
        return UIFont(name: "BarlowCondensed-SemiBold", size: size)
    }
    
    static func akrobatExtraboldFont(size: CGFloat) -> UIFont? {
        return UIFont(name: "Akrobat-Extrabold", size: size)
    }
}
