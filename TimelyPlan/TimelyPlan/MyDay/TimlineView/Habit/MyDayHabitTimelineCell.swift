//
//  MyDayHabitTimelineCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation
import UIKit

class MyDayHabitTimelineCell: TimelineCell {
    
    /// 习惯记录供应器
    weak var recordProvider: MyDayHabitRecordProvider?
    
    private var habitItem: TimelineItem?
    
    private var habitTask: HabitTask?
    
    private let iconNodeView = HabitTimelineNodeView()
    
    private lazy var infoView: HabitTimelineInfoView = {
        let view = HabitTimelineInfoView()
        view.recordButton.addTarget(self,
                                    action: #selector(clickRecord(_:)),
                                    for: .touchUpInside)
        return view
    }()
    
    private let requestManager = TPRequestManager()
    
    private let processor = HabitTaskMenuActionProcessor()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        requestManager.executeRequest()
        recordProvider?.removeUpdaterDelegate(self)
        recordProvider = nil
        
        iconNodeView.setStatus(.notStarted)
        iconNodeView.setProgress(0.0)
    }
    
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
    
    func configure(with item: TimelineItem, recordProvider: MyDayHabitRecordProvider?) {
        configure(with: item)
        
        self.recordProvider = recordProvider
        self.recordProvider?.addUpdaterDelegate(self)
        self.habitItem = item
        self.habitTask = item.event.sourceItem as? HabitTask
        guard let task = habitTask else {
            return
        }
        
        configureAppearance(for: task)
        loadRecordAndUpdateDisplay()
        setNeedsLayout()
    }

    private func configureAppearance(for task: HabitTask) {
        iconNodeView.configure(icon: task.icon)
        infoView.resetRecordButton()
        infoView.configureColor(task.color)
        infoView.title = task.displayName
        infoView.subtitle = task.goal.targetDescription
    }

    private func loadRecordAndUpdateDisplay() {
        guard let task = habitTask, let date = habitItem?.startDate else {
            return
        }
        
        let requestID = requestManager.executeRequest()
        recordProvider?.fetchRecord(for: task, on: date) { [weak self] record in
            guard let self = self,
                  let item = self.habitItem else {
                      return
                  }
            
            guard self.requestManager.shouldProceed(with: requestID),
                  task.identifier == self.habitTask?.identifier,
                  item.startDate.isInSameDayAs(date) else {
                return
            }

            self.refreshDisplay(for: task, on: date, with: record)
        }
    }

    private func refreshDisplay(for task: HabitTask,
                                on date: Date,
                                with record: HabitRecord?,
                                animated: Bool = false) {
        updateStatusAndProgress(for: task, with: record, animated: animated)
        updateInfoView(for: task, on: date, with: record)
        setNeedsLayout()
    }

    private func updateStatusAndProgress(for task: HabitTask,
                                         with record: HabitRecord?,
                                         animated: Bool = false) {
        let status = task.status(with: record)
        iconNodeView.setStatus(status, animated: animated)
        
        let progress = task.progress(with: record)
        iconNodeView.setProgress(progress, animated: animated)
    }

    private func updateInfoView(for task: HabitTask, on date: Date, with record: HabitRecord?) {
        infoView.updateRecordButton(for: task, on: date, with: record)
        if !date.isFutureDay {
            infoView.subtitle = HabitTaskDetailProvider.completedAmountDetail(for: task, with: record)
        }
    }
    
    @objc private func clickRecord(_ button: UIButton) {
        guard let habitTask = habitTask, let date = habitItem?.startDate else {
            return
        }

        processor.clickRecrod(for: habitTask, on: date)
    }
    
    private func didChangeRecord(withIncreament amount: Int) {
        guard amount != 0 else { return }
        let text = (amount >= 0 ? "+" : "") + "\(amount)"
        let color = habitItem?.nodeColor ?? .label
        let font = BOLD_SYSTEM_FONT
        let fromView = infoView
        let sourceWidth = text.width(with: font)
        let sourceRect = CGRect(x: 0.0, y: 0.0, width: sourceWidth, height: fromView.height)
        
        TPTextPopUp.showText(text,
                             color: color,
                             font: font,
                             fromView: infoView,
                             sourceRect: sourceRect,
                             containerView: superview)
    }
    
}

extension MyDayHabitTimelineCell: HabitRecordProcessorDelegate {
    
    func didUpdateHabitRecord(_ record: HabitRecord, for task: HabitTask, on date: Date, with change: HabitRecordChange) {
        guard let currentDate = habitItem?.startDate,
              currentDate.isInSameDayAs(date),
                task.identifier == habitTask?.identifier else {
                    return
                }
        
        refreshDisplay(for: task, on: date, with: record, animated: true)
        
        if case let .amountChanged(oldValue, newValue) = change {
            didChangeRecord(withIncreament: Int(newValue - oldValue))
        }
    }
    

    func didChangeRemoteHabitRecord(with results: EntityChangeResults<HabitRecord>?) {
        loadRecordAndUpdateDisplay()
    }
    
    func didDeleteHabitRecords(for task: HabitTask?, in dateRange: DateRange) {
        guard let date = habitItem?.startDate,
              let currentTask = habitTask,
                dateRange.contains(date: date) else {
            return
        }

        var shouldUpdate = true
        if let task = task, task.identifier != currentTask.identifier {
            shouldUpdate = false
        }
        
        if shouldUpdate {
            refreshDisplay(for: currentTask, on: date, with: nil, animated: true)
        }
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
    
    private(set) lazy var titleView: TPInfoView = {
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
    
    func resetRecordButton() {
        self.actionType = .none
        setNeedsLayout()
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
