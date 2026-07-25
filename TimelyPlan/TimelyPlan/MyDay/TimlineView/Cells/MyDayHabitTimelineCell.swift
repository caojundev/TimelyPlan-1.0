//
//  MyDayHabitTimelineCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation
import UIKit

class MyDayHabitTimelineCell: TimelineCell {
    
    private var habitItem: TimelineItem?
    
    private let iconNodeView = HabitTimelineNodeView()
    
    private lazy var infoView: HabitTimelineInfoView = {
        let view = HabitTimelineInfoView()
        return view
    }()
    
    override func setupNodeView() {
        self.nodeView = iconNodeView
    }
    
    override func setupEventContentSubviews() {
        eventContentView.addSubview(infoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = eventContentView.bounds
    }
    
    override func configure(with item: TimelineItem) {
        super.configure(with: item)
        self.habitItem = item
        guard let task = item.event?.sourceItem as? HabitTask else {
            return
        }
        
        let date = item.startDate
        iconNodeView.configure(icon: task.icon)
        infoView.configureColor(task.color)
        infoView.title = task.displayName
        infoView.subtitle = task.goal.targetDescription
        infoView.updateRecordButton(for: task, on: date, with: nil)
        setNeedsLayout()
    }
}

class HabitTimelineInfoView: UIView {

    var title: TextRepresentable? {
        get { return titleView.title }
        set { titleView.title = newValue }
    }
    
    var subtitle: TextRepresentable? {
        get { return titleView.subtitle }
        set { titleView.subtitle = newValue }
    }
    
    private lazy var titleView: TPInfoView = {
        let view = TPInfoView()
        view.padding = .zero
        view.titleConfig.textAlignment = .left
        view.titleConfig.font = MyDayTimelineConfig.titleFont
        view.subtitleConfig.textAlignment = .left
        view.subtitleConfig.font = MyDayTimelineConfig.subtitleFont
        view.subtitleLabel.alpha = 0.6
        return view
    }()
    
    private var actionType: HabitDayActionButtonType = .none
    
    /// 记录按钮最大宽度
    private let recordButtonMaxWidth = 100.0

    /// 记录按钮
    private(set) lazy var recordButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = UIEdgeInsets(top: 3.0,
                                      left: 6.0,
                                      bottom: 3.0,
                                      right: 12.0)
        button.titleConfig.font = .boldSystemFont(ofSize: 12.0)
        button.imageConfig.size = .size(5)
        button.imageConfig.margins = .zero
        button.imageConfig.shouldRenderImageWithColor = true
        button.preferredTappedScale = 0.9
        button.scaleMaxLength = 5.0
        button.cornerRadius = .greatestFiniteMagnitude
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        padding = .zero
        addSubview(titleView)
        addSubview(recordButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        titleView.frame = layoutFrame
        
        var titleViewWidth = layoutFrame.maxX - titleView.left
        recordButton.sizeToFit()
        if actionType == .record {
            /// 记录
            recordButton.alpha = 1.0
            if recordButton.width > recordButtonMaxWidth {
                recordButton.width = recordButtonMaxWidth
            }
            
            recordButton.right = layoutFrame.maxX
            titleViewWidth = recordButton.left - titleView.left
        } else if actionType == .resetToday {
            recordButton.alpha = 0.0
            recordButton.right = layoutFrame.maxX
        } else {
            recordButton.alpha = 0.0
            recordButton.right = layoutFrame.maxX
        }
        
        titleView.width = titleViewWidth
        recordButton.centerYEqualToView(titleView)
    }
    
    func configureColor(_ color: UIColor) {
        recordButton.imageConfig.color = .white
        recordButton.titleConfig.textColor = .white
        recordButton.normalBackgroundColor = color
    }
    
    func updateRecordButton(for task: HabitTask,
                            on date: Date,
                            with record: HabitRecord?) {
        self.actionType = .actionButtonType(for: task, on: date, with: record)
        var imageName: String
        var title: String
        if task.goal.mode == .checkin {
            imageName = "HabitRecordTypeCheckin"
            title = resGetString("Check-in")
        } else {
            let recordType = task.goal.validatedRecordType
            switch recordType {
            case .completeAll:
                imageName = "HabitRecordTypeCompleteAll"
                title = resGetString("Done")
            case .automatically:
                imageName = "HabitRecordTypeAutoAdd"
                title = "\(task.goal.validatedRecordAmount)"
            default:
                imageName = "HabitRecordTypeManually"
                title = resGetString("Input")
            }
        }
        
        recordButton.image = resGetImage(imageName)
        recordButton.title = title
        setNeedsLayout()
    }
}

class HabitTimelineNodeView: TimelineNodeView {

    let iconSize = CGSize(width: 32.0, height: 32.0)
    
    /// 任务图标视图
    lazy var iconView: TPIconView = {
        let view = TPIconView()
        view.borderWidth = 0.0
        view.placeholderCharacter = "C"
        view.size = iconSize
        view.cornerRadius = iconSize.halfHeight
        view.backColor = Color(0xcccccc, 0.1)
        return view
    }()
    
    /// 进度视图
    lazy var progressView: TPCircleOutlineProgressView = {
        let view = TPCircleOutlineProgressView()
        view.progressLineWidth = 3.2
        view.backLineColor = Color(0x000000, 0.4)
        return view
    }()
    
    /// 任务状态视图
    lazy var statusView: HabitTaskStatusView = {
        let view = HabitTaskStatusView(frame: bounds)
        return view
    }()

    override func setupView() {
        contentView.addSubview(iconView)
        contentView.addSubview(progressView)
        contentView.addSubview(statusView)
    }

    // MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        iconView.frame = CGRect(
            x: (contentView.width - iconSize.width) / 2,
            y: (contentView.height - iconSize.height) / 2,
            width: iconSize.width,
            height: iconSize.height
        )
        
        progressView.frame = iconView.frame
        progressView.radius = iconSize.halfHeight
        statusView.frame = iconView.frame
    }

    override func configureBackgroundColor(_ color: UIColor) {
        super.configureBackgroundColor(color)
        progressView.progressLineColor = color.lighterColor
    }
    
    func configure(icon: TPIcon,
                   progress: CGFloat = 0.0,
                   status: HabitTaskStatus = .notStarted) {
        iconView.icon = icon
        progressView.progress = progress
        statusView.setStatus(status)
    }
    
    func setProgress(_ progress: CGFloat, animated: Bool = false) {
        progressView.setProgress(progress, animated: animated)
    }
    
    func setStatus(_ status: HabitTaskStatus, animated: Bool = false) {
        statusView.setStatus(status, animated: animated)
    }
    
}
