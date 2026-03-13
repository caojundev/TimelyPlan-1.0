//
//  HabitRecordResultInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/13.
//

import Foundation

class HabitRecordResultInfoView: UIView, TPCustomPopupContent {
    
    var didClickLog: (() -> Void)?
    
    private var infoView = TPImageInfoView()
    
    private lazy var logButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.image = resGetImage("habit_menu_log_24")
        button.imageConfig.color = .white
        button.normalBackgroundColor = Color(0x456FEF)
        button.cornerRadius = .greatestFiniteMagnitude
        button.addTarget(self, action: #selector(clickLog(_:)), for: .touchUpInside)
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
        self.backgroundColor = .secondarySystemBackground
        self.padding = UIEdgeInsets(left: 16.0, right: 16.0)
        infoView.imageConfig.shouldRenderImageWithColor = false
        addSubview(infoView)
        addSubview(logButton)
        
        infoView.imageContent = .withName("habit_status_completed_24")
        infoView.title = "习惯标题"
        infoView.subtitle = "已完成 已跳过 已失败"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        logButton.size = .init(width: 48.0, height: 32.0)
        logButton.right = layoutFrame.maxX
        logButton.centerY = layoutFrame.midY
    
        infoView.width = logButton.left - layoutFrame.minX
        infoView.height = layoutFrame.height
        infoView.origin = layoutFrame.origin
    }
    
    @objc func clickLog(_ button: UIButton) {
        TPImpactFeedback.impactWithSoftStyle()
        didClickLog?()
    }
}
