//
//  HabitUnitButtonView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/28.
//

import Foundation
import UIKit

class HabitUnitButtonView: UIView {

    /// 单位改变回调
    var unitDidChange: ((String) -> Void)?
    
    /// 单位文本
    var unit: String? {
        didSet {
            button.title = unit ?? placeholderUnit
        }
    }
    
    var placeholderUnit: String = resGetString("count")

    /// 内部封装按钮
    private lazy var button: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 5)
        button.cornerRadius = kTaskEditInputFieldCornerRadius
        button.preferredTappedScale = 0.9
        button.imagePosition = .right
        button.imageConfig.shouldRenderImageWithColor = true
        button.imageConfig.color = .secondaryLabel
        button.titleConfig.textAlignment = .center
        button.titleConfig.font = BOLD_SYSTEM_FONT
        button.image = resGetImage("chevron_down_24")
        button.normalBackgroundColor = .secondarySystemFill
        button.selectedBackgroundColor = .tertiarySystemFill
        button.addTarget(self,
                         action: #selector(clickButton(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    override var backgroundColor: UIColor? {
        get {
            return button.normalBackgroundColor
        }
        
        set {
            button.normalBackgroundColor = newValue
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(button)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return button.sizeThatFits(size)
    }
    
    @objc func clickButton(_ button: UIButton){
        let vc = HabitUnitManageViewController()
        vc.didSelectUnit = { unit in
            self.unit = unit
            self.unitDidChange?(unit)
        }

        let navController = UINavigationController(rootViewController: vc)
        navController.popoverShow(from: button,
                                  sourceRect: button.bounds.insetBy(dx: -4.0, dy: -4.0),
                                  isSourceViewCovered: true,
                                  preferredPosition: .bottomLeft,
                                  permittedPositions: [.bottomLeft, .topLeft],
                                  animated: true,
                                  completion: nil)        
    }
}
