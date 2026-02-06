//
//  TaskAddView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/24.
//

import Foundation
import UIKit

class TodoTaskAddView: TPFlipContainerView {
    
    /// 添加按钮
    private lazy var addButton: TPDefaultButton = {
        let button = button(imageName: "plus_32",
                            imageColor: .white,
                            backgroundColor: Color(0x456FEF))
        button.addTarget(self, action: #selector(clickAdd(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 点击添加
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
        self.addSubview(self.addButton)
    }
    
    func buttons() -> [TPDefaultButton] {
        return [self.addButton]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.setLayerShadow(color: .shadow, offset: .zero, radius: 8.0)
        self.addButton.cornerRadius = .greatestFiniteMagnitude
    }
    
    func button(imageName: String,
                imageColor: UIColor,
                backgroundColor: UIColor) -> TPDefaultButton {
        let button = TPDefaultButton()
        button.normalBackgroundColor = backgroundColor
        button.selectedBackgroundColor = backgroundColor
        button.image = resGetImage(imageName)
        button.imageConfig.color = imageColor
        return button
    }
    
    @objc func clickAdd(_ button: TPDefaultButton) {
        TPImpactFeedback.impactWithMediumStyle()
        self.didClickAdd?(button)
    }
}
