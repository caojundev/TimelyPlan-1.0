//
//  GanttTimelineScaleCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/24.
//

import UIKit

// MARK: - 刻度 Cell 基类

/// 时间轴 header 的刻度单元 cell 基类
class GanttTimelineScaleCell: UICollectionViewCell {
    
    /// 左侧竖线（区分相邻单元）
    let separatorLine = UIView()

    /// 是否为主要边界（月首等），用于强调竖线与标题
    private(set) var isMajorBoundary: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        backgroundColor = .clear
        separatorLine.backgroundColor = GanttTimelineConfig.headerSeparatorColor
        contentView.addSubview(separatorLine)
    }

    func configure(with unit: GanttTimelineScaleUnit) {
        isMajorBoundary = unit.isMajorBoundary
        setNeedsLayout()
    }

    private func applyBoundaryStyle() {
        separatorLine.backgroundColor = GanttTimelineConfig.headerSeparatorColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyBoundaryStyle()
        separatorLine.frame = CGRect(x: 0, y: 0, width: 1.0, height: bounds.height)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isMajorBoundary = false
    }
}

// MARK: - 日刻度 Cell

final class GanttTimelineDayCell: GanttTimelineScaleCell {
    
    static let dayReuseIdentifier = "GanttTimelineDayCell"
    
    private let infoView = CalendarWeekDayInfoView()
    
    override func setupViews() {
        super.setupViews()
        contentView.addSubview(infoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = contentView.bounds
    }
    
    override func configure(with unit: GanttTimelineScaleUnit) {
        let config = CalendarMonthDayConfig(date: unit.startDate)
        infoView.update(with: config)
    }
}

// MARK: - 周刻度 Cell

final class GanttTimelineWeekCell: GanttTimelineScaleCell {

    static let weekReuseIdentifier = "GanttTimelineWeekCell"

    /// 周数标签
    let numberLabel = TPLabel()
    
    /// 日期标签
    let dateLabel = TPLabel()
    
    override func setupViews() {
        super.setupViews()
        numberLabel.edgeInsets = UIEdgeInsets(horizontal: 8.0)
        numberLabel.textAlignment = .left
        numberLabel.font = .boldSystemFont(ofSize: 12.0)
        numberLabel.textColor = .secondaryLabel

        dateLabel.edgeInsets = UIEdgeInsets(horizontal: 8.0)
        dateLabel.textAlignment = .left
        dateLabel.font = .boldSystemFont(ofSize: 16.0)
        dateLabel.textColor = .label
        contentView.addSubview(numberLabel)
        contentView.addSubview(dateLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        numberLabel.width = bounds.width
        numberLabel.height = 20.0
        numberLabel.bottom = bounds.height / 2.0
        
        dateLabel.width = bounds.width
        dateLabel.height = 24.0
        dateLabel.top = bounds.height / 2.0
        
    }
    
    override func configure(with unit: GanttTimelineScaleUnit) {
        super.configure(with: unit)
        
        let weekNumber = Calendar.weekNumber(for: unit.endDate, firstWeekday: .sunday)
        let weekNumberFormat = resGetString("W%ld")
        numberLabel.text = String(format: weekNumberFormat, weekNumber)
        dateLabel.text = "\(unit.startDate.slashFormattedMonthDayString)"
        setNeedsLayout()
    }
}

// MARK: - 月刻度 Cell

final class GanttTimelineMonthCell: GanttTimelineScaleCell {
    static let monthReuseIdentifier = "GanttTimelineMonthCell"

    /// 日期标签
    let dateLabel = TPLabel()
    
    override func setupViews() {
        super.setupViews()
        dateLabel.edgeInsets = UIEdgeInsets(horizontal: 8.0)
        dateLabel.textAlignment = .center
        dateLabel.font = .boldSystemFont(ofSize: 16.0)
        dateLabel.textColor = .label
        contentView.addSubview(dateLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dateLabel.frame = bounds
    }
    
    override func configure(with unit: GanttTimelineScaleUnit) {
        super.configure(with: unit)
        
        dateLabel.text = unit.startDate.shortMonthSymbol
        setNeedsLayout()
    }
}
