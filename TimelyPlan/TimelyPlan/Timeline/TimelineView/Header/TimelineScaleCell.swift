//
//  TimelineScaleCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/24.
//

import UIKit

// MARK: - 刻度 Cell 基类

/// 时间轴 header 的刻度单元 cell 基类
class TimelineScaleCell: UICollectionViewCell {

    /// 主标题 label（如 "2026年8月" / "W35"）
    let titleLabel = UILabel()
    /// 副标题 label（如 "24" / "8/24"）
    let subtitleLabel = UILabel()
    /// 左侧竖线（区分相邻单元）
    let separatorLine = UIView()

    /// 是否为主要边界（月首等），用于强调竖线与标题
    var isMajorBoundary: Bool = false {
        didSet { applyBoundaryStyle() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .clear

        titleLabel.font = UIFont.boldSystemFont(ofSize: 11)
        titleLabel.textColor = .darkText

        subtitleLabel.font = UIFont.systemFont(ofSize: 9)
        subtitleLabel.textColor = .gray

        separatorLine.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)

        contentView.addSubview(separatorLine)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
    }

    func configure(with unit: TimelineScaleUnit) {
        titleLabel.text = unit.title
        subtitleLabel.text = unit.subtitle
        subtitleLabel.isHidden = (unit.subtitle == nil || unit.subtitle?.isEmpty == true)
        isMajorBoundary = unit.isMajorBoundary
        setNeedsLayout()
    }

    private func applyBoundaryStyle() {
        separatorLine.backgroundColor = isMajorBoundary
            ? UIColor.gray
            : UIColor.lightGray.withAlphaComponent(0.3)
        titleLabel.font = isMajorBoundary
            ? UIFont.boldSystemFont(ofSize: 11)
            : UIFont.systemFont(ofSize: 10)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // 竖线在左侧边缘
        separatorLine.frame = CGRect(x: 0, y: 0, width: 1, height: bounds.height)

        // 主标题在上，副标题在下
        titleLabel.frame = CGRect(x: 4, y: 4, width: bounds.width - 8, height: 14)
        subtitleLabel.frame = CGRect(x: 4, y: 20, width: bounds.width - 8, height: 12)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        subtitleLabel.isHidden = true
        isMajorBoundary = false
    }
}

// MARK: - 日刻度 Cell

final class TimelineDayCell: TimelineScaleCell {
    static let dayReuseIdentifier = "TimelineDayCell"

    override func configure(with unit: TimelineScaleUnit) {
        // 日刻度：主标题只在月初显示月份，副标题显示日期
        titleLabel.text = unit.title
        subtitleLabel.text = unit.subtitle
        subtitleLabel.isHidden = false
        isMajorBoundary = unit.isMajorBoundary
        setNeedsLayout()
    }
}

// MARK: - 周刻度 Cell

final class TimelineWeekCell: TimelineScaleCell {
    static let weekReuseIdentifier = "TimelineWeekCell"

    override func configure(with unit: TimelineScaleUnit) {
        // 周刻度：主标题显示周数，副标题显示起始日期
        titleLabel.text = unit.title
        subtitleLabel.text = unit.subtitle
        subtitleLabel.isHidden = false
        isMajorBoundary = true
        setNeedsLayout()
    }
}

// MARK: - 月刻度 Cell

final class TimelineMonthCell: TimelineScaleCell {
    static let monthReuseIdentifier = "TimelineMonthCell"

    override func layoutSubviews() {
        super.layoutSubviews()

        // 月刻度：主标题垂直居中
        titleLabel.frame = CGRect(x: 4, y: (bounds.height - 16) / 2, width: bounds.width - 8, height: 16)
    }

    override func configure(with unit: TimelineScaleUnit) {
        titleLabel.text = unit.title
        subtitleLabel.text = nil
        subtitleLabel.isHidden = true
        isMajorBoundary = true
        setNeedsLayout()
    }
}
