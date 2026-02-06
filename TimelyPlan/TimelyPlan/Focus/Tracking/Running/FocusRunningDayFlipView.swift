//
//  FocusRunningTopbarClockView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/21.
//

import Foundation
import UIKit

class FocusRunningDayFlipView: UIView, TPMidnightUpdatable {
    
    private lazy var dayView: FlipClockCardView = {
        let view = FlipClockCardView()
        view.contentPadding = UIEdgeInsets(value: -2.0)
        view.cornerRadius = 4.0
        view.separatorSpacing = 1.5
        view.separatorLineHeight = 0.0
        view.shadowColor = .clear
        view.shadowRadius = 0.0
        view.font = .akrobatExtraboldFont(size: 36.0)
        view.textColor = Color(light: 0xffffff, dark: 0x000000)
        view.backColor = resGetColor(.title)
        view.separatorLineColor = resGetColor(.title)
        view.setText("00", animated: false)
        return view
    }()
    
    private let dayViewSize = CGSize(width: 22.0, height: 20.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        clipsToBounds = false
        addSubview(dayView)
        
        /// 添加至凌晨更新对象
        TPMidnightScheduler.shared.addUpdater(self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.updateAtMidnight()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dayView.size = dayViewSize
        dayView.alignCenter()
    }
    
    // MARK: - Update
    func updateAtMidnight() {
        let dayString = String(format: "%02ld", Date.now.day)
        dayView.setText(dayString, animated: true)
    }
}
