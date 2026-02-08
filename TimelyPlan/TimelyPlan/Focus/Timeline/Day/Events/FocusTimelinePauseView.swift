//
//  FocusTimelinePauseView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/8.
//

import Foundation

class FocusTimelinePauseView: UIView {
    
    /// 暂停图层
    private let pauseLayer = TPSlashLayer()
    
    /// 暂停遮罩
    private let pauseMaskLayer = CAShapeLayer()
    
    var timeline: FocusRecordTimeline? {
        didSet {
            updatePauseMaskLayerPath()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.pauseLayer.mask = pauseMaskLayer
        self.pauseLayer.backgroundColor = Color(0x010101).cgColor
        self.layer.addSublayer(pauseLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pauseLayer.frame = bounds
        updatePauseMaskLayerPath()
    }
    
    func updatePauseMaskLayerPath() {
        guard let timeline = timeline else {
            pauseLayer.path = nil
            return
        }

        let totalInterval = timeline.totalInterval
        guard totalInterval > 0.0, let pauseFragments = timeline.pauseTimeFragments else {
            pauseLayer.path = nil
            return
        }
        
        let bezierPath = UIBezierPath()
        for pauseFragment in pauseFragments {
            let offset = pauseFragment.startDate.timeIntervalSince(timeline.startDate)
            let y = bounds.height * (offset / totalInterval)
            let h = bounds.height * (pauseFragment.interval / totalInterval)
            let rect = CGRect(x: 0, y: y, width: bounds.width, height: h)
            bezierPath.addRect(rect)
        }
        
        pauseMaskLayer.path = bezierPath.cgPath
    }
}
