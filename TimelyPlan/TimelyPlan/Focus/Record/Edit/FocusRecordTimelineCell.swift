//
//  FocusRecordTimelineCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/10.
//

import Foundation

class FocusRecordDurationCellItem: FocusRecordTimelineCellItem {
    
    var recordDuration: FocusRecordDuration {
        didSet {
            updateInfo()
        }
    }
    
    init(recordDuration: FocusRecordDuration) {
        self.recordDuration = recordDuration
        super.init()
        self.accessoryType = .disclosureIndicator
        self.updateInfo()
    }
    
    func updateInfo() {
        var imageName: String
        var title: String
        if recordDuration.type == .pause {
            imageName = "focus_record_timeline_paused_24"
            title = resGetString("Pause")
        } else {
            imageName = "focus_record_timeline_focus_24"
            title = resGetString("Focus")
        }
        
        self.imageName = imageName
        self.title = title
        self.subtitle = Duration(recordDuration.interval).localizedTitle
    }
}


class FocusRecordTimelineCellItem: TPImageInfoTextValueTableCellItem {
    
    /// 实现县
    var timelineStyle: FocusRecordTimelineLayer.TimelineStyle = .both
    
    override init() {
        super.init()
        self.registerClass = FocusRecordTimelineCell.self
        self.contentPadding = UIEdgeInsets(left: 16.0, right: 16.0)
        self.height = 60.0
    }
}

class FocusRecordTimelineCell: TPImageInfoTextValueTableCell {

    override var cellItem: TPBaseTableCellItem? {
        didSet {
            let cellItem = cellItem as? FocusRecordTimelineCellItem
            self.timelineLayer.timelineStyle = cellItem?.timelineStyle ?? .both
        }
    }
    
    var timelineLayer = FocusRecordTimelineLayer()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layer.addSublayer(timelineLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        timelineLayer.strokeColor = UIColor.systemGray4.cgColor
        timelineLayer.frame = CGRect(x: layoutFrame.minX,
                                     y: 0.0,
                                     width: 24.0,
                                     height: bounds.height)
        CATransaction.commit()
    }
    
}

class FocusRecordTimelineLayer: CAShapeLayer {
    
    /// 绘制样式
    enum TimelineStyle {
        case both
        case top
        case bottom
    }
    
    var timelineStyle: TimelineStyle = .both {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        setupLayer()
    }
    
    override init() {
        super.init()
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayer() {
        fillColor = UIColor.clear.cgColor
        strokeColor = UIColor.white.cgColor
        lineCap = .round
        lineJoin = .round
        lineWidth = 2.0
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        updateLayerPath()
    }
    
    private func updateLayerPath() {
        let bezierPath = UIBezierPath()
        let dotRadius = 10.0
        let dotMargin = 4.0
        
        if timelineStyle == .both || timelineStyle == .top {
            bezierPath.move(to: CGPoint(x: bounds.width / 2.0, y: 0.0))
            bezierPath.addLine(to: CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0 - dotRadius - dotMargin))
        }
    
        if timelineStyle == .both || timelineStyle == .bottom {
            bezierPath.move(to: CGPoint(x: bounds.width / 2.0, y: bounds.height))
            bezierPath.addLine(to: CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0 + dotRadius + dotMargin))
        }
    
        self.path = bezierPath.cgPath
    }
}
