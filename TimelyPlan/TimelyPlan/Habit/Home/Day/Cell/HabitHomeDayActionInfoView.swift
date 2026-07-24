//
//  HabitHomeDayActionInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/8.
//

import Foundation

/// 按钮显示模式
enum HabitDayActionButtonType {
    case none /// 无按钮
    case resetToday /// 重置今日
    case record /// 记录按钮
}

extension HabitDayActionButtonType {
    
    static func actionButtonType(for periodItem: HabitPeriodItem) -> HabitDayActionButtonType {
        let task = periodItem.habitTask
        let date = periodItem.period.date
        let record = periodItem.records?[date.dayIntegerKey]
        return actionButtonType(for: task, on: date, with: record)
    }
    
    static func actionButtonType(for task: HabitTask,
                                 on date: Date,
                                 with record: HabitRecord?) -> HabitDayActionButtonType {
        if date.isFutureDay {
            return .none
        }
        
        let status = task.status(with: record)
        if status.isSkipped || status.isFailed {
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

    private(set) var actionType: HabitDayActionButtonType = .none
    
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
    
    func updateRecordButton(with periodItem: HabitPeriodItem?) {
        guard let periodItem = periodItem else {
            self.actionType = .none
            self.recordButton.image = nil
            self.recordButton.title = nil
            setNeedsLayout()
            return
        }

        self.actionType = HabitDayActionButtonType.actionButtonType(for: periodItem)
        let habitTask = periodItem.habitTask
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
                title = resGetString("Done")
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

}
