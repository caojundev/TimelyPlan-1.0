//
//  AlarmRelativeOffsetEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/9.
//

import Foundation

class AlarmRelativeOffsetEditViewController: TPViewController {
    
    var alarm: TaskAlarm = TaskAlarm()
    
    var didEndEditing: ((TaskAlarm) -> Void)?
    
    var pickerView: AlarmRelativeOffsetPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = popoverContentSize
        setupActionsBar(actions:  [cancelAction, doneAction])
        pickerView = AlarmRelativeOffsetPickerView()
        view.addSubview(pickerView)
        reloadData()
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
            alarm = TaskAlarm(weeksRelative: (intervalCount, duration))
        } else {
            alarm = TaskAlarm(daysRelative: (intervalCount, duration))
        }
    
        didEndEditing?(alarm)
        dismiss(animated: true, completion: nil)
    }
    
    func reloadData() {
        pickerView.reloadData()
    }
}
