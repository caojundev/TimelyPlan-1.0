//
//  FocusStartActionView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/20.
//

import Foundation

class FocusStartActionView: TPAnimatedContainerView {
    
    enum Mode {
        case waiting
        case focusing
    }

    /// 是否已显示
    var isDisplaying: Bool = false {
        didSet {
            updateFocusingAnimation()
        }
    }

    /// 模式
    var mode: Mode = .waiting {
        didSet {
            if mode != oldValue {
                updateContentView(animated: false)
            }
        }
    }
    
    /// 点击开始
    var didClickStart: (() -> Void)?
    
    /// 点击专注中
    var didClickFocusing: (() -> Void)?
    
    /// 开始按钮
    private lazy var startButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.titleConfig.font = BOLD_SYSTEM_FONT
        button.title = resGetString("Start Focus")
        button.titleConfig.textColor = .white
        button.normalBackgroundColor = .primary
        button.cornerRadius = .greatestFiniteMagnitude
        button.addTarget(self, action: #selector(clickStart), for: .touchUpInside)
        return button
    }()
    
    /// 计时中按钮
    private lazy var focusingButton: FocusStartFocusingButton = {
        let button = FocusStartFocusingButton()
        button.addTarget(self, action: #selector(clickFocusing), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(value: 5.0)
        self.updateContentView(animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func contentViewFrame() -> CGRect {
        return layoutFrame()
    }
    
    // MARK: - 更新内容视图
    private func updateContentView(animated: Bool) {
        if mode == .waiting {
            setContentView(startButton, animateStyle: .none)
        } else {
            setContentView(focusingButton, animateStyle: .none)
        }
        
        updateFocusingAnimation()
    }
    
    private func updateFocusingAnimation() {
        guard mode == .focusing else {
            focusingButton.stopAnimation()
            return
        }
        
        if isDisplaying {
            focusingButton.startAnimation()
        }else  {
            focusingButton.stopAnimation()
        }
    }
    
    // MARK: - Event Response
    @objc private func clickStart() {
        didClickStart?()
    }
    
    @objc private func clickFocusing() {
        didClickFocusing?()
    }
}

fileprivate class FocusStartFocusingButton: TPDefaultButton {
    
    private let indicatorView = TPWaveIndicatorView()
    
    private let indicatorSize: CGSize = .size(5)
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        padding = UIEdgeInsets(horizontal: 48.0)
        
        indicatorView.lineWidth = 2.0
        indicatorView.lineHeight = 16.0
        indicatorView.lineHeight = indicatorSize.height
        indicatorView.lineColor = Color(0x4A4DFF)
        contentView.addSubview(indicatorView)
        
        title = resGetString("Focusing")
        titleConfig.font = BOLD_SYSTEM_FONT
        cornerRadius = .greatestFiniteMagnitude
        borderWidth = 3.0
        titleConfig.textColor = Color(0x4A4DFF)
        normalBorderColor = Color(0x4A4DFF)
        normalBackgroundColor = .clear
        selectedBackgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        indicatorView.size = indicatorSize
        indicatorView.right = layoutFrame.minX
        indicatorView.alignVerticalCenter()
    }

    func startAnimation() {
        indicatorView.startAnimation()
        indicatorView.isHidden = false
    }
    
    func stopAnimation() {
        indicatorView.stopAnimation()
        indicatorView.isHidden = true
    }
}
