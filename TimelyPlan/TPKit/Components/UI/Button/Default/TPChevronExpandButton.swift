//
//  TFExpandChevronButton.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/30.
//

import Foundation
import UIKit

class TPChevronExpandButton: TPDefaultButton {
    
    var isExpanded: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.padding = .zero
        self.image = resGetImage("triangle_right_12")
        self.imageConfig.size = .size(3)
        self.imageConfig.margins = UIEdgeInsets(right: 4.0)
        self.imageConfig.color = resGetColor(.title)
        self.titleConfig.textColor = resGetColor(.title)
    }
    
    override func layoutSubviews() {
        self.imageTitleView.imageView.transform = .identity
        super.layoutSubviews()
        if isExpanded {
            self.imageTitleView.imageView.transform = .init(rotationAngle: CGFloat.pi / 2.0)
        }
    }
    
    func setExpanded(_ expanded: Bool, animated: Bool) {
        isExpanded = expanded
        if animated {
            animateLayout(withDuration: 0.25)
        }
    }
}
