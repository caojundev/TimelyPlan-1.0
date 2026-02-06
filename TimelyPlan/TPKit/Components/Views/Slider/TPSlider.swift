//
//  TPSlider.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/21.
//

import Foundation
import UIKit

class TPSlider : UISlider {
    
    /// 线条高度
    var trackLineHeight: CGFloat = 6.0
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let y = (bounds.height - trackLineHeight) / 2.0
        return CGRect(x: 0.0, y: y, width: bounds.width, height: trackLineHeight)
    }
}
