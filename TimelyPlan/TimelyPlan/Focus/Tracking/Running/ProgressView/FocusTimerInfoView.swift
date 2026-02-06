//
//  FocusTimeInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/5.
//

import Foundation
import UIKit

class FocusTimerInfoView: UIView {

    var alarmDate: Date? {
        didSet {
            updateAlarmTitle()
        }
    }
    
    /// 时间标签
    lazy var timeLabel: TPLabel = {
        let label = TPLabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 64.0, weight: .semibold)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = "00:00"
        return label
    }()
    
    /// 提醒标题视图
    var alarmTitleHeight = 30.0
    lazy var alarmTitleLabel: TPLabel = {
        let label = TPLabel()
        label.font = BOLD_SYSTEM_FONT
        label.textAlignment = .center
        return label
    }()
    
    /// 副标题
    var subtitleHeight = 30.0
    lazy var subtitleLabel: TPLabel = {
        let label = TPLabel()
        label.font = BOLD_SYSTEM_FONT
        label.textAlignment = .center
        return label
    }()
    
    /// 内容视图
    private let contentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isMultipleTouchEnabled = false
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        addSubview(self.contentView)
        self.contentView.addSubview(self.timeLabel)
        self.contentView.addSubview(self.alarmTitleLabel)
        self.contentView.addSubview(self.subtitleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timeLabel.frame = bounds
        let titleColor = UIColor.label.withAlphaComponent(0.6)
        alarmTitleLabel.width = bounds.width
        alarmTitleLabel.height = alarmTitleHeight
        alarmTitleLabel.bottom = timeLabel.top
        alarmTitleLabel.textColor = titleColor
        
        subtitleLabel.width = bounds.width
        subtitleLabel.height = subtitleHeight
        subtitleLabel.top = timeLabel.bottom
        subtitleLabel.textColor = titleColor
    }
    
    private func updateAlarmTitle() {
        guard let alarmTimeText = alarmDate?.timeString else {
            alarmTitleLabel.text = nil
            return
        }
        
        if let alarmImage = resGetImage("bell_fill_16") {
            let imageColor = UIColor.label.withAlphaComponent(0.6)
            let attributedTitle: ASAttributedString = .string(image: alarmImage,
                                                              imageSize: .size(4),
                                                              imageColor: imageColor,
                                                              trailingText: alarmTimeText,
                                                              separator: nil)
            alarmTitleLabel.attributed.text = attributedTitle
        } else {
            alarmTitleLabel.text = alarmTimeText
        }
    }
    
    func setInfoHidden(_ isHidden: Bool, animated: Bool) {
        let alpha = isHidden ? 0.0 : 1.0
        guard animated else {
            alarmTitleLabel.alpha = alpha
            subtitleLabel.alpha = alpha
            return
        }
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .beginFromCurrentState,
                       animations: {
            self.alarmTitleLabel.alpha = alpha
            self.subtitleLabel.alpha = alpha
        }, completion: nil)
    }
}
