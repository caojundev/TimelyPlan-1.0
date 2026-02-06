//
//  TPHoldActionView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/6.
//

import Foundation
import UIKit

class TPHoldActionView: UIView {
    
    var handler: (() -> Void)?
    
    private let contentView = UIView()
    
    private lazy var progressView: TPBarProgressView = {
        let view = TPBarProgressView(frame: .zero)
        view.cornerRadius = .greatestFiniteMagnitude
        view.barForeColor = resGetColor(.title)
        view.barBackColor = .systemGray5
        return view
    }()

    private lazy var titleLabel: TPLabel = {
        let label = TPLabel()
        label.font = BOLD_SYSTEM_FONT
        label.textAlignment = .center
        label.text = resGetString("Hold To Stop")
        label.textColor = resGetColor(.title)
        return label
    }()
    
    private lazy var countingView: TPPeriodicCountingView = { [weak self] in
        let view = TPPeriodicCountingView()
        view.targetInterval = 0.5
        view.didStartCounting = {
            self?.didStartCounting()
        }
        
        view.didStopCounting = { isCompleted in
            self?.didStopCounting()
            if isCompleted {
                self?.handler?()
            }
        }
        
        view.repeatHandler = { interval in
            self?.updateProgress(interval, animated: false)
        }
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        contentView.clipsToBounds = false
        contentView.addSubview(progressView)
        contentView.addSubview(titleLabel)
        addSubview(contentView)
        addSubview(countingView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        countingView.frame = bounds
        contentView.transform = .identity
        contentView.frame = bounds

        progressView.width = 160.0
        progressView.height = 6.0
        progressView.top = 2.0
        progressView.alignHorizontalCenter()
        titleLabel.frame = bounds.inset(by: UIEdgeInsets(top: 10.0))
        
        updateContentStyle()
    }
    
    private func updateContentStyle() {
        if countingView.isCounting {
            contentView.transform = .init(scaleX: 0.8, y: 0.8)
            titleLabel.alpha = 0.8
            progressView.alpha = 1.0
        } else {
            titleLabel.alpha = 0.6
            progressView.alpha = 0.0
        }
    }

    // MARK: - Counting Handler
    private func updateProgress(_ interval: TimeInterval, animated: Bool = false) {
        let targetInterval = countingView.targetInterval
        let progress = validatedProgress(interval / targetInterval)
        progressView.setProgress(progress, animated: animated)
    }
    
    private func didStartCounting() {
        TPImpactFeedback.impactWithLightStyle()
        animateLayout(withDuration: 0.1)
    }
    
    private func didStopCounting() {
        animateLayout(withDuration: 0.1)
        progressView.progress = 0.0
    }
    
    func stopCounting() {
        countingView.stopCounting()
    }
}
