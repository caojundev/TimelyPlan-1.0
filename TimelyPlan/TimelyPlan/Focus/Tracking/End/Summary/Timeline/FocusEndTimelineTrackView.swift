//
//  FocusEndTimelineTrackView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/13.
//

import Foundation
import UIKit

class FocusEndTimelineTrackView: UIView {

    private lazy var startDateLabel: TPLabel = {
        let label = TPLabel()
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.textColor = resGetColor(.title)
        label.alpha = 0.6
        return label
    }()
    
    private lazy var endDateLabel: TPLabel = {
        let label = TPLabel()
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.textColor = resGetColor(.title)
        label.alpha = 0.6
        return label
    }()
    
    private lazy var timelineBar: FocusEndTimelineBar = {
        let view = FocusEndTimelineBar()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(top: 6.0, bottom: 2.0)
        self.addSubview(timelineBar)
        self.addSubview(startDateLabel)
        self.addSubview(endDateLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = self.layoutFrame()
        
        startDateLabel.sizeToFit()
        startDateLabel.height = 30.0
        startDateLabel.origin = layoutFrame.origin
        
        endDateLabel.sizeToFit()
        endDateLabel.height = startDateLabel.height
        endDateLabel.right = layoutFrame.maxX
        endDateLabel.top = startDateLabel.top
        
        timelineBar.layer.cornerRadius = 8.0
        timelineBar.width = layoutFrame.width
        timelineBar.height = 28.0
        timelineBar.top = startDateLabel.bottom
        timelineBar.left = layoutFrame.minX
    }

    func reloadData(with dataItem: FocusEndDataItem?) {
        timelineBar.reloadData(with: dataItem)
        guard let dataItem = dataItem else {
            startDateLabel.text = "--"
            endDateLabel.text = "--"
            return
        }

        let startFormat = resGetString("Start from %@")
        startDateLabel.text = String(format: startFormat, dataItem.startDate.timeString)
        let endFormat = resGetString("Ended at %@")
        endDateLabel.text = String(format: endFormat, dataItem.endDate.timeString)
    }
    
}
