//
//  FocusTimerBindView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/9.
//

import Foundation

import UIKit

class FocusTimerBindView: UIView {
    
    /// 当前任务改变
    var didBindTimer: ((FocusTimerRepresentable?) -> Void)?
    
    /// 当前计时器
    var timer: FocusTimerRepresentable? {
        didSet {
            updateTimerName(animated: true)
        }
    }

    /// 计时器按钮
    private lazy var timerButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.titleConfig.font = BOLD_SYSTEM_FONT
        button.imagePosition = .right
        button.imageConfig.margins = UIEdgeInsets(value: 5.0)
        button.titleConfig.textColor = resGetColor(.title)
        button.imageConfig.color = resGetColor(.title)
        button.addTarget(self,
                         action: #selector(didClickTimer(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(timerButton)
        updateTimerName(animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = bounds.inset(by: UIEdgeInsets(horizontal: 10.0))
        timerButton.sizeToFit()
        if timerButton.width > layoutFrame.width {
            timerButton.width = layoutFrame.width
        }
        
        timerButton.center = layoutFrame.center
    }
    
    /// 更新任务名称
    private func updateTimerName(animated: Bool) {
        if let timer = timer {
            let name = timer.name ?? resGetString("Untitled")
            timerButton.title = name
        } else {
            timerButton.title = resGetString("Select Timer")
        }
        
        if animated {
            animateLayout(withDuration: 0.25)
        } else {
            setNeedsLayout()
        }
    }
    
    /// 点击任务
    @objc func didClickTimer(_ button: UIButton) {
        TPImpactFeedback.impactWithLightStyle()
        FocusTimerPickerViewController.show(with: timer) { timer in
            self.timer = timer
            self.didBindTimer?(timer)
        }
    }
    
}
