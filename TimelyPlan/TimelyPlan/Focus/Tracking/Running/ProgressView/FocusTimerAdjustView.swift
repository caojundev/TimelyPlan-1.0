//
//  FocusTimeView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/2.
//

import UIKit

class FocusTimerAdjustView: TPAutoRemoveView {

    var dateRange: DateRange? {
        didSet {
            self.updateDateRange()
        }
    }
    
    /// 点击减号
    var didClickDecrease: (() -> Void)?
    
    var canDecrease: Bool {
        get {
            return buttonView.canDecrease
        }
        
        set {
            buttonView.canDecrease = newValue
        }
    }
    
    /// 点击加号
    var didClickIncrease: (() -> Void)?
    
    /// 是否可以增加
    var canIncrease: Bool {
        get {
            return buttonView.canIncrease
        }
        
        set {
            buttonView.canIncrease = newValue
        }
    }
    
    /// 信息视图布局
    var infoViewFrame: CGRect? {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 按钮视图
    let buttonViewSize = CGSize(width: 160.0, height: 40.0)
    private(set) lazy var buttonView: FocusTimerAdjustButtonView = {
        let view = FocusTimerAdjustButtonView()
        view.size = buttonViewSize
        view.didClickIncrease = { [weak self] in
            TPImpactFeedback.impactWithSoftStyle()
            self?.restartTimer()
            self?.didClickIncrease?()
        }
        
        view.didClickDecrease = { [weak self] in
            TPImpactFeedback.impactWithSoftStyle()
            self?.restartTimer()
            self?.didClickDecrease?()
        }
        
        return view
    }()
    
    /// 时间标签
    var timeLabelSize = CGSize(width: 160.0, height: 30.0)
    private lazy var timeLabel: TPLabel = {
        let label = TPLabel()
        label.size = timeLabelSize
        label.alpha = 0.8
        label.textAlignment = .center
        label.textColor = .label
        label.font = BOLD_SYSTEM_FONT
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(timeLabel)
        addSubview(buttonView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let infoViewFrame = infoViewFrame else {
            return
        }
        
        timeLabel.size = timeLabelSize
        timeLabel.bottom = infoViewFrame.minY
        timeLabel.centerX = infoViewFrame.midX
        
        buttonView.size = buttonViewSize
        buttonView.top = infoViewFrame.maxY
        buttonView.centerX = infoViewFrame.midX
    }
    
    func updateDateRange() {
        guard let dateRange = dateRange else {
            self.timeLabel.text = nil
            return
        }
        
        self.timeLabel.attributed.text = dateRange.attributedTimeRange()
    }
    
}

class FocusTimerAdjustButtonView: UIView {
    
    var canDecrease: Bool {
        get {
            return decreaseButton.isEnabled
        }
        
        set {
            decreaseButton.isEnabled = newValue
        }
    }
    
    var canIncrease: Bool {
        get {
            return increaseButton.isEnabled
        }
        
        set {
            increaseButton.isEnabled = newValue
        }
    }
    
    var didClickDecrease: (() -> Void)?
    
    var didClickIncrease: (() -> Void)?

    let buttonSize = CGSize(width: 40.0, height: 40.0)
    
    /// 减少按钮
    private(set) lazy var decreaseButton: TPDefaultButton = {
        let button = button(imageName: "NegativeCircleFill")
        button.imageConfig.size = .default
        button.addTarget(self, action: #selector(clickDecrease(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 增加按钮
    private(set) lazy var increaseButton: TPDefaultButton = {
        let button = button(imageName: "PositiveCircleFill")
        button.imageConfig.size = .default
        button.addTarget(self, action: #selector(clickIncrease(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = false
        addSubview(decreaseButton)
        addSubview(increaseButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        decreaseButton.size = buttonSize
        decreaseButton.alignVerticalCenter()
        increaseButton.size = buttonSize
        increaseButton.right = bounds.width
        increaseButton.alignVerticalCenter()
    }
    
    // MARK: - 调整当前步骤时间
    @objc func clickIncrease(_ button: UIButton) {
        TPImpactFeedback.impactWithSoftStyle()
        didClickIncrease?()
    }
    
    @objc func clickDecrease(_ button: UIButton) {
        TPImpactFeedback.impactWithSoftStyle()
        didClickDecrease?()
    }
    
    // MARK: - Helpers
    func button(imageName: String) -> TPDefaultButton {
        let button = TPDefaultButton()
        button.padding = .zero
        button.image = resGetImage(imageName)
        button.imageConfig.color = UIColor.label
        button.hitTestEdgeInsets = UIEdgeInsets(value: -15.0)
        return button
    }
}
