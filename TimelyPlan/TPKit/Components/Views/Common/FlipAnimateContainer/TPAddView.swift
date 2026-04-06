//
//  TPAddView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/26.
//
import Foundation
import UIKit

class TPAddView: TPFlipAnimateContainerView {

    var normalBackgroundColor: UIColor? {
        get {
            return addButton.normalBackgroundColor
        }
        
        set {
            addButton.normalBackgroundColor = newValue
        }
    }
    
    private let shadowRadius: CGFloat = 8.0

    lazy var addButton: TPImageButton = {
        let button = TPImageButton()
        button.normalImage = resGetImage("plus_32")
        button.normalImageColor = .white
        button.normalBackgroundColor = Color(0x456FEF)
        button.cornerRadius = .greatestFiniteMagnitude
        button.addTarget(self, action: #selector(clickAdd(_:)), for: .touchUpInside)
        return button
    }()
    
    var didClickAdd: ((UIButton) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        self.views = buttons()
        setActiveView(addButton, animated: false)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
        self.views = buttons()
        setActiveView(addButton, animated: false)
    }
    
    func setupSubviews() {
        self.clipsToBounds = false
        addSubview(addButton)
    }
    
    func buttons() -> [UIButton] {
        return [addButton]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.setLayerShadow(color: Color(0x000000, 0.25),
                             offset: .zero,
                             radius: shadowRadius)
    }
    
    @objc func clickAdd(_ button: UIButton) {
        TPImpactFeedback.impactWithSoftStyle()
        didClickAdd?(button)
    }
    
    func showAddButton() {
        setActiveView(addButton, animated: true)
    }
}
