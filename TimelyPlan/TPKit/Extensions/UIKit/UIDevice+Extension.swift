//
//  UIDevice+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/11.
//

import Foundation
import UIKit

extension UIDevice {
    
    var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
