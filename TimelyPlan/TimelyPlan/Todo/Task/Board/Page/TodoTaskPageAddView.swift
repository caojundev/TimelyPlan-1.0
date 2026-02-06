//
//  TodoTaskPageAddView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/16.
//

import Foundation
import UIKit

class TodoTaskPageAddView: UIView {
    
    /// 点击添加回调
    var didClickAdd: (() -> Void)?
    
    /// 当前视图是否固定在底部
    var isFixed: Bool = false {
        didSet {
            if isFixed != oldValue {
                updateStyle()
            }
        }
    }

    var cornerRadius: CGFloat = 12.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var addButton = TPDefaultButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        self.padding = UIEdgeInsets(top: 8.0, left: 4.0, bottom: 4.0, right: 4.0)
        addButton.scaleMaxLength = 8.0
        addButton.imageConfig.margins = UIEdgeInsets(value: 5.0)
        addButton.image = resGetImage("plus_24")
        addButton.title = resGetString("Add Task")
        addButton.normalBackgroundColor = .secondarySystemGroupedBackground
        addButton.selectedBackgroundColor = .secondarySystemGroupedBackground
        addButton.addTarget(self, action: #selector(clickAdd(_:)), for: .touchUpInside)
        addSubview(addButton)
        addSeparator(position: .top)
        updateStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addButton.cornerRadius = cornerRadius
        addButton.frame = layoutFrame()
        addButton.setBorderShadow(color: Color(0x222222, 0.2),
                                  offset: .zero,
                                  radius: 4.0,
                                  roundCorners: .allCorners,
                                  cornerRadius: cornerRadius)
    }
    
    private func updateStyle() {
        if isFixed {
            self.backgroundColor = .systemBackground
            self.separatorView?.isHidden = false
        } else {
            self.backgroundColor = .clear
            self.separatorView?.isHidden = true
        }
    }
    
    @objc private func clickAdd(_ button: UIButton) {
        didClickAdd?()
    }
    
}
