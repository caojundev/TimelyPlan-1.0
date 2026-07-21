//
//  MyDayFocusTimelineCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation
import UIKit

class MyDayFocusTimelineCell: TimelineIconCell {

    private var focusItem: TimelineItem?
    
    /// 开始按钮
    lazy var startButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = UIEdgeInsets(value: 10.0)
        button.hitTestEdgeInsets = UIEdgeInsets(value: -10.0)
        button.image = resGetImage("triangle_right_32")
        button.imageConfig.color = .primary
        button.addTarget(self, action: #selector(clickStart(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var infoView: TPInfoView = {
        let view = TPInfoView()
        view.titleConfig.font = .systemFont(ofSize: 16, weight: .bold)
        view.titleConfig.textColor = .label
        view.titleConfig.numberOfLines = 1
        view.subtitleConfig.font = .systemFont(ofSize: 12, weight: .regular)
        view.subtitleConfig.textColor = .secondaryLabel
        return view
    }()
    
    override func setupEventContentSubviews() {
        infoView.rightAccessoryView = startButton
        infoView.rightAccessorySize = .mini
        infoView.rightAccessoryMargins = UIEdgeInsets(left: 6.0, right: 12.0)
        eventContentView.addSubview(infoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = eventContentView.bounds
    }
    
    override func configure(with item: TimelineItem) {
        super.configure(with: item)
        self.focusItem = item
        infoView.title = item.title
        infoView.subtitle = item.durationText
        
        let icon = FocusTimerType.pomodoro.iconImage?.withTintColor(.white)
        iconNodeView.configureIcon(icon)
        setNeedsLayout()
    }

    @objc func clickStart(_ button: UIButton) {
        print("开始专注")
    }
    
}

