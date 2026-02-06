//
//  StopwatchTimerProgressView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/14.
//

import Foundation
import UIKit

class StopwatchTimerProgressView: UIView {
    
    private let progressView = WatchTickView()
    private let tickView = WatchTickView()

    var scaleColor: UIColor = .label.withAlphaComponent(0.2) {
        didSet {
            tickView.scaleColor = scaleColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tickView.scaleColor = scaleColor
        tickView.scaleLineWidth = 6.0
        tickView.scaleLength = 12.0
        addSubview(tickView)
        
        progressView.scaleColor = kFocusStopwatchTimerColor
        progressView.scaleLineWidth = 6.0
        progressView.scaleLength = 12.0
        progressView.strokeEnd = 0.0
        addSubview(progressView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tickView.frame = bounds
        progressView.frame = bounds
    }
    
    // MARK: - Public Methods
    public func setDuration(_ duration: TimeInterval) {
        let progress = duration.seconds / Double(SECONDS_PER_MINUTE)
        progressView.strokeEnd = progress
    }

    public func commitStrokeAnimation() {
        tickView.commitStrokeAnimation()
    }
}
