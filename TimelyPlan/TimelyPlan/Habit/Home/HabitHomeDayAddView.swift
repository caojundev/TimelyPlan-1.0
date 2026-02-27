//
//  HabitHomeDayAddView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/26.
//
import Foundation
import UIKit

class HabitTaskAddView: TPFlipAnimateContainerView {
    
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

class HabitHomeDayAddView: HabitTaskAddView {
    
    lazy var leftBackButton: TPImageButton = {
        let button = TPImageButton()
        button.normalImage = resGetImage("arrow_up_right_fill_36")
        button.normalImageColor = .white
        button.normalBackgroundColor = Color(0xFF9500)
        button.cornerRadius = .greatestFiniteMagnitude
        button.addTarget(self, action: #selector(clickBack(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var rightBackButton: TPImageButton = {
        let button = TPImageButton()
        button.normalImage = resGetImage("arrow_up_backward_fill_36")
        button.normalImageColor = .white
        button.normalBackgroundColor = Color(0xFF9500)
        button.cornerRadius = .greatestFiniteMagnitude
        button.addTarget(self,
                         action: #selector(clickBack(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    var didClickBack: ((UIButton) -> Void)?
    
    override func buttons() -> [UIButton] {
        return [addButton, leftBackButton, rightBackButton]
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        addSubview(leftBackButton)
        addSubview(rightBackButton)
    }
    
    @objc func clickBack(_ button: UIButton) {
        TPImpactFeedback.impactWithSoftStyle()
        didClickBack?(button)
    }
    
    func isBackButtonActive() -> Bool {
        return activeView == leftBackButton || activeView == rightBackButton
    }
    
    func showRightBackButton() {
        setActiveView(rightBackButton, animated: true)
    }
    
    func showLeftBackButton() {
        setActiveView(leftBackButton, animated: true)
    }
}
