//
//  TimelineAllDayFooterView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/21.
//

import Foundation
import UIKit

class TimelineAllDayFooterView: UICollectionReusableView {
    
    var onToggleTapped: (() -> Void)?
    
    private let toggleButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.titleConfig.font = .boldSystemFont(ofSize: 12.0)
        button.titleConfig.textColor = .primary
        button.imageConfig.color = .primary
        button.imageConfig.size = .size(3)
        button.imageConfig.shouldRenderImageWithColor = true
        
        button.preferredTappedScale = 0.9
        button.scaleMaxLength = 5.0
        button.imageConfig.margins = UIEdgeInsets(right: 2.0)
        button.padding = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 20.0)
        return button
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(toggleButton)
        toggleButton.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        toggleButton.sizeToFit()
        toggleButton.alignCenter()
    }
    
    
    // MARK: - Configuration
    
    func configure(hiddenCount: Int, isExpanded: Bool) {
        if isExpanded {
            toggleButton.title = resGetString("Collapse")
            toggleButton.image = resGetImage("triangle_up_12")
        } else {
            let format = resGetString("%ld more all-day events")
            toggleButton.title = String(format: format, hiddenCount)
            toggleButton.image = resGetImage("triangle_down_12")
        }
        
        setNeedsLayout()
    }
    
    // MARK: - Actions
    
    @objc private func toggleButtonTapped() {
        onToggleTapped?()
    }
}
