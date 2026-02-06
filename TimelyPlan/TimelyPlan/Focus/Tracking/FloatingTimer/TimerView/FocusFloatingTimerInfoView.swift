//
//  FocusFloatingTimerInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/25.
//

import Foundation
import UIKit

class FocusFloatingTimerInfoView: UIView {
    
    /// 时间标签
    let timeLabel: TPLabel = {
        let label = TPLabel()
        label.font = .robotoMonoBoldFont(size: 24.0)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.text = "00:00"
        return label
    }()

    override var tintColor: UIColor! {
        didSet {
            timeLabel.textColor = tintColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 5.0)
        self.addSubview(timeLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.timeLabel.frame = layoutFrame()
    }
    
    func update(with timerInfo: FocusTimerInfo?) {
        guard let timerInfo = timerInfo else {
            return
        }

        let duration: TimeInterval
        if timerInfo.timerType == .countdown {
            /// 倒计时
            duration = timerInfo.remainDuration
            timeLabel.text = timerInfo.remainDuration.timeString
        } else {
            /// 正计时
            duration = timerInfo.elapsedDuration
        }
        
        if duration >= 60000 {
            /// 时：分：秒
            timeLabel.text = duration.timeString
        } else {
            /// 分：秒
            timeLabel.text = duration.timeString(withStyle: .minuteSecond)
        }
    }
}
