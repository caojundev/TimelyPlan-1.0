//
//  AlarmAbsoluteOffsetEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/9.
//

import Foundation

class AlarmAbsoluteOffsetEditViewController: TPViewController {
    
    var didEndEditing: ((TaskAlarm) -> Void)?
    
    var pickerView: AlarmAbsoluteOffsetPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = popoverContentSize
        let actions = [cancelAction, doneAction]
        setupActionsBar(actions: actions)
        
        pickerView = AlarmAbsoluteOffsetPickerView()
        pickerView.reloadData()
        view.addSubview(pickerView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.layoutFrame()
        pickerView.width = layoutFrame.width
        pickerView.height = layoutFrame.height - actionsBarHeight
        pickerView.origin = layoutFrame.origin
    }
    
    override var popoverContentSize: CGSize {
        return .Popover.mini
    }

    override func clickDone() {
        TPImpactFeedback.impactWithLightStyle()
        
        let intervalType = pickerView.intervalType
        let intervalCount = pickerView.intervalCount
        let duration = pickerView.offsetDuration
        var alarm: TaskAlarm
        if intervalType == .weekBefore {
            alarm = TaskAlarm(weeksAbsolute: (intervalCount, duration))
        } else {
            alarm = TaskAlarm(daysAbsolute: (intervalCount, duration))
        }
    
        didEndEditing?(alarm)
        dismiss(animated: true, completion: nil)
    }
}
