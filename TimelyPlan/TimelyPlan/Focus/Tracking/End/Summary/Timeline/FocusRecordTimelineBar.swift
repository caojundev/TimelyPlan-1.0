//
//  FocusTimelineBar.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/18.
//

import Foundation
import UIKit

class FocusRecordTimelineBar: UIView {
    
    /// 暂停图层
    private let pauseLayer = TPSlashLayer()
    
    /// 暂停遮罩
    private let pauseMaskLayer = CAShapeLayer()
    
    var timeline: FocusRecordTimeline
    
    init(timeline: FocusRecordTimeline) {
        self.timeline = timeline
        super.init(frame: .zero)
        self.backgroundColor = .primary
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
        
        let totalInterval = timeline.totalInterval
        guard totalInterval > 0.0, let pauseFragments = timeline.pauseTimeFragments else {
            pauseLayer.path = nil
            return
        }
        
        let bezierPath = UIBezierPath()
        for pauseFragment in pauseFragments {
            let offset = pauseFragment.startDate.timeIntervalSince(timeline.startDate)
            let x = bounds.width * (offset / totalInterval)
            let w = bounds.width * (pauseFragment.interval / totalInterval)
            let rect = CGRect(x: x, y: 0, width: w, height: bounds.height)
            bezierPath.addRect(rect)
        }
        
        pauseMaskLayer.path = bezierPath.cgPath
    }
}
