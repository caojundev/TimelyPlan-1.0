//
//  HabitHomeDayActionInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/8.
//

import Foundation

extension HabitHomeDayActionInfoView.ActionButtonType {
    
    static func actionButtonType(for task: HabitPeriodTask) -> HabitHomeDayActionInfoView.ActionButtonType {
        let date = task.period.date
        if date.isFutureDay {
            return .none
        }
        
        let record = task.records?[date.dayIntegerKey]
        let status = task.taskStatus(with: record)
        if status == .skipped(nil) || status == .failed(nil) {
            return .resetToday
        }
        
        if status == .completed {
            let amount = record?.amount ?? 0
            if amount == 0 {
                return .none
            }
            
            return .resetToday
        }
        
        return .record
    }
}

class HabitHomeDayActionInfoView: HabitTaskProgressInfoView {
    
    /// 按钮显示模式
    enum ActionButtonType {
        case none /// 无按钮
        case resetToday /// 重置今日
        case record /// 记录按钮
    }

    private(set) var actionType: ActionButtonType = .none
    
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
        button.normalBackgroundColor = UIColor(white: 1.0, alpha: 0.85)
        button.addTarget(self,
                         action: #selector(clickRecord(_:)),
                         for: .touchUpInside)
       return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(recordButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        var infoViewWidth = layoutFrame.width
        
        recordButton.sizeToFit()
        if actionType == .record {
            /// 记录
            recordButton.alpha = 1.0
            if recordButton.width > recordButtonMaxWidth {
                recordButton.width = recordButtonMaxWidth
            }
            
            recordButton.right = layoutFrame.maxX
            
//            resetTodayButton.alpha = 0.0
//            resetTodayButton.right = layoutFrame.maxX
            infoViewWidth = recordButton.left - layoutFrame.minX
        } else if actionType == .resetToday {
            recordButton.alpha = 0.0
            recordButton.right = layoutFrame.maxX
            
//            resetTodayButton.alpha = 1.0
//            resetTodayButton.right = layoutFrame.maxX
//            infoViewWidth = resetTodayButton.left - layoutFrame.minX
        } else {
            recordButton.alpha = 0.0
            recordButton.right = layoutFrame.maxX
        }
        
        titleView.width = infoViewWidth
        recordButton.centerYEqualToView(titleView)
    }
    
    func updateRecordButton(with task: HabitPeriodTask?) {
        guard let task = task else {
            self.actionType = .none
            self.recordButton.image = nil
            self.recordButton.title = nil
            setNeedsLayout()
            return
        }

        self.actionType = ActionButtonType.actionButtonType(for: task)
        let habitTask = task.habitTask
        let color = habitTask.color.darkerColor
        recordButton.titleConfig.textColor = color
        recordButton.imageConfig.color = color
        
        var imageName: String
        var title: String
        if habitTask.goal.mode == .checkin {
            imageName = "HabitRecordTypeCheckin"
            title = resGetString("Check-in")
        } else {
            let recordType = habitTask.goal.validatedRecordType
            switch recordType {
            case .completeAll:
                imageName = "HabitRecordTypeCompleteAll"
                title = resGetString("Complete")
            case .automatically:
                imageName = "HabitRecordTypeAutoAdd"
                title = "\(habitTask.goal.validatedRecordAmount)"
            default:
                imageName = "HabitRecordTypeManually"
                title = resGetString("Input")
            }
        }
        
        recordButton.image = resGetImage(imageName)
        recordButton.title = title
        setNeedsLayout()
    }
    
    func actionButtonType(for task: HabitPeriodTask) -> ActionButtonType {
        let date = task.period.date
        if date.isFutureDay {
            return .none
        }
        
        let record = task.records?[date.dayIntegerKey]
        let status = task.taskStatus(with: record)
        if status == .skipped(nil) || status == .failed(nil) {
            return .resetToday
        }
        
        if status == .completed {
            let amount = record?.amount ?? 0
            if amount == 0 {
                return .none
            }
            
            return .resetToday
        }
        
        return .record
    }
    
    // MARK: - Event Response
    @objc private func clickRecord(_ button: UIButton) {
//        if let delegate = delegate as? HabitTodayCellDelegate {
//            delegate.habitTodayCellClickRecord(self)
//        }
    }
    
}
