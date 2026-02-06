//
//  TPSliderViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/1.
//

import Foundation
import UIKit

class TPSliderViewController: TPViewController {
    
    var didChangeValue: ((Float) -> Void)?
    
    var minimumValue: Float {
        get {
            return slider.minimumValue
        }
        
        set {
            slider.minimumValue = newValue
        }
    }
    
    var maximumValue: Float {
        get {
            return slider.maximumValue
        }
        
        set {
            slider.maximumValue = newValue
        }
    }
    
    var value: Float {
        get {
            return slider.value
        }
        
        set {
            slider.value = newValue
        }
    }
    
    private let sliderHeight = 4.0
    
    private lazy var slider: TPSlider = {
        let slider = TPSlider()
        slider.tintColor = .primary
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 260.0, height: 60.0)
        view.addSubview(slider)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.bounds.inset(by: UIEdgeInsets(horizontal: 16.0))
        slider.hitTestEdgeInsets = UIEdgeInsets(value: -16.0)
        slider.width = layoutFrame.width
        slider.height = sliderHeight
        slider.left = layoutFrame.minX
        slider.centerY = layoutFrame.midY
    }
    
    @objc private func sliderValueChanged(_ slider: UISlider) {
        didChangeValue?(slider.value)
    }
}
