//
//  TodoStepAddView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/11.
//

import Foundation
import UIKit

class TodoStepAddView: UIView {
    
    var didClickAdd: (() -> Void)?
    
    private lazy var addButton: TPImageInfoButton = {
        let button = TPImageInfoButton()
        button.preferredTappedScale = 1.0
        button.selectedBackgroundColor = .secondarySystemFill
        button.padding = UIEdgeInsets(horizontal: 16.0, vertical: 5.0)
        button.addTarget(self,
                         action: #selector(clickAdd(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        let infoView = addButton.imageInfoView
        infoView.titleConfig.font = BOLD_SYSTEM_FONT
        infoView.titleConfig.textAlignment = .left
        infoView.imageContent = .withName("plus_24")
        infoView.imageConfig.size = .mini
        infoView.title = resGetString("Add Step")
        addSubview(addButton)
        addSeparator(position: .top)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addButton.frame = bounds
    }
    
    @objc private func clickAdd(_ button: UIButton) {
        didClickAdd?()
    }
}
