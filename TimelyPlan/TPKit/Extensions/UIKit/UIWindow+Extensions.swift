//
//  UIWindow+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/13.
//

import Foundation
import UIKit

extension UIWindow {
    
    static var keyWindow: UIWindow? {
        if let result = UIApplication.shared.delegate?.window {
            return result
        }
        
        for windowScene in UIApplication.shared.connectedScenes {
            if let windowScene = windowScene as? UIWindowScene,
                    windowScene.activationState == .foregroundActive {
                return windowScene.windows.first
            }
        }
        
        return nil
    }
}
