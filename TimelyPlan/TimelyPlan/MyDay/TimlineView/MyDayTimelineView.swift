//
//  MyDayTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation
import UIKit

class MyDayTodoTimelineCell: TimelineCell {
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let durationLabel = UILabel()
    private let rightCircleView = UIView()
    
    private var todoItem: TimelineItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTodoUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupTodoUI() {
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        
        durationLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        durationLabel.textColor = .lightGray
        durationLabel.textAlignment = .center
        durationLabel.layer.cornerRadius = 4
        durationLabel.layer.masksToBounds = true
        durationLabel.backgroundColor = UIColor(white: 0.3, alpha: 0.5)
        
        rightCircleView.layer.borderWidth = 2
        rightCircleView.backgroundColor = .clear
        
        eventContentView.addSubview(titleLabel)
        eventContentView.addSubview(subtitleLabel)
        eventContentView.addSubview(durationLabel)
        eventContentView.addSubview(rightCircleView)
    }
    
    override func configure(with item: TimelineItem) {
        super.configure(with: item)
        self.todoItem = item
        
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        durationLabel.text = item.durationText
        durationLabel.isHidden = item.durationText == nil
        
        rightCircleView.layer.borderColor = item.isCompleted ? item.nodeColor.cgColor : UIColor.gray.cgColor
        rightCircleView.layer.cornerRadius = TimelineConfig.rightCircleSize / 2
        rightCircleView.backgroundColor = item.isCompleted ? item.nodeColor.withAlphaComponent(0.2) : .clear
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = eventContentView.bounds
        let verticalCenterY = bounds.height / 2
        
        if !durationLabel.isHidden {
            durationLabel.sizeToFit()
            durationLabel.frame = CGRect(
                x: 0,
                y: verticalCenterY - 30,
                width: durationLabel.bounds.width + 12,
                height: durationLabel.bounds.height + 4
            )
        }
        
        let titleY = durationLabel.isHidden ? verticalCenterY - 10 : verticalCenterY - 8
        let textMaxWidth = bounds.width - TimelineConfig.rightCircleSize - 8
        let titleSize = titleLabel.sizeThatFits(CGSize(width: textMaxWidth, height: .greatestFiniteMagnitude))
        titleLabel.frame = CGRect(
            x: 0,
            y: titleY,
            width: min(titleSize.width, textMaxWidth),
            height: titleSize.height
        )
        
        if let subtitle = todoItem?.subtitle, !subtitle.isEmpty {
            subtitleLabel.isHidden = false
            subtitleLabel.sizeToFit()
            subtitleLabel.frame = CGRect(
                x: 0,
                y: titleLabel.frame.maxY + 4,
                width: min(textMaxWidth, subtitleLabel.bounds.width),
                height: subtitleLabel.bounds.height
            )
        } else {
            subtitleLabel.isHidden = true
        }
        
        rightCircleView.frame = CGRect(
            x: bounds.width - TimelineConfig.rightCircleSize,
            y: verticalCenterY - TimelineConfig.rightCircleSize / 2,
            width: TimelineConfig.rightCircleSize,
            height: TimelineConfig.rightCircleSize
        )
    }
}

// MARK: - Focus 事件 Cell

class MyDayFocusTimelineCell: TimelineCell {
    
    private let titleLabel = UILabel()
    private let durationLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    
    private var focusItem: TimelineItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFocusUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupFocusUI() {
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        durationLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        durationLabel.textColor = .lightGray
        
        progressView.trackTintColor = UIColor(white: 0.3, alpha: 0.5)
        progressView.progressTintColor = .systemGreen
        
        eventContentView.addSubview(titleLabel)
        eventContentView.addSubview(durationLabel)
        eventContentView.addSubview(progressView)
    }
    
    override func configure(with item: TimelineItem) {
        super.configure(with: item)
        self.focusItem = item
        
        titleLabel.text = item.title
        durationLabel.text = item.durationText
        
        // 根据完成状态设置进度
        progressView.progress = item.isCompleted ? 1.0 : 0.5
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = eventContentView.bounds
        let verticalCenterY = bounds.height / 2
        
        let textMaxWidth = bounds.width
        
        let titleSize = titleLabel.sizeThatFits(CGSize(width: textMaxWidth, height: .greatestFiniteMagnitude))
        titleLabel.frame = CGRect(
            x: 0,
            y: verticalCenterY - 25,
            width: min(titleSize.width, textMaxWidth),
            height: titleSize.height
        )
        
        durationLabel.sizeToFit()
        durationLabel.frame = CGRect(
            x: 0,
            y: titleLabel.frame.maxY + 4,
            width: durationLabel.bounds.width,
            height: durationLabel.bounds.height
        )
        
        progressView.frame = CGRect(
            x: 0,
            y: durationLabel.frame.maxY + 6,
            width: textMaxWidth,
            height: 4
        )
    }
}

// MARK: - Habit 事件 Cell

class MyDayHabitTimelineCell: TimelineCell {
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    
    private var habitItem: TimelineItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHabitUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupHabitUI() {
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        
        checkmarkImageView.contentMode = .center
        checkmarkImageView.tintColor = .systemGreen
        
        eventContentView.addSubview(titleLabel)
        eventContentView.addSubview(subtitleLabel)
        eventContentView.addSubview(checkmarkImageView)
    }
    
    override func configure(with item: TimelineItem) {
        super.configure(with: item)
        self.habitItem = item
        
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        
        if item.isCompleted {
            checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            checkmarkImageView.image = UIImage(systemName: "circle")
        }
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = eventContentView.bounds
        let verticalCenterY = bounds.height / 2
        
        let checkmarkSize: CGFloat = 24
        checkmarkImageView.frame = CGRect(
            x: bounds.width - checkmarkSize,
            y: verticalCenterY - checkmarkSize / 2,
            width: checkmarkSize,
            height: checkmarkSize
        )
        
        let textMaxWidth = bounds.width - checkmarkSize - 8
        let titleSize = titleLabel.sizeThatFits(CGSize(width: textMaxWidth, height: .greatestFiniteMagnitude))
        titleLabel.frame = CGRect(
            x: 0,
            y: verticalCenterY - 12,
            width: min(titleSize.width, textMaxWidth),
            height: titleSize.height
        )
        
        subtitleLabel.sizeToFit()
        subtitleLabel.frame = CGRect(
            x: 0,
            y: titleLabel.frame.maxY + 2,
            width: min(textMaxWidth, subtitleLabel.bounds.width),
            height: subtitleLabel.bounds.height
        )
    }
}

// MARK: - MyDayTimelineView

class MyDayTimelineView: TimelineView {
    
    override func eventCellClass(for item: TimelineItem) -> AnyClass {
        guard let event = item.event else {
            return MyDayTodoTimelineCell.self
        }
        
        switch event.source {
        case .todo:
            return MyDayTodoTimelineCell.self
        case .focus:
            return MyDayFocusTimelineCell.self
        case .habit:
            return MyDayHabitTimelineCell.self
        }
    }
    
    override func configureEventCell(_ cell: TimelineCell, with item: TimelineItem) {
        // 根据不同类型进行特定配置
        if let todoCell = cell as? MyDayTodoTimelineCell {
            todoCell.configure(with: item)
        } else if let focusCell = cell as? MyDayFocusTimelineCell {
            focusCell.configure(with: item)
        } else if let habitCell = cell as? MyDayHabitTimelineCell {
            habitCell.configure(with: item)
        } else {
            cell.configure(with: item)
        }
    }
}
