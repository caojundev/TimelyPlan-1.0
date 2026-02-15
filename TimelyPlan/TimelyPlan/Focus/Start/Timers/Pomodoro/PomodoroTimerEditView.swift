//
//  PomodoroTimerEditView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/15.
//

import Foundation
import UIKit

class PomodoroTimerEditView: UIView {
    
    /// 番茄圆环尺寸
    let circleSize = CGSize(width: 280.0, height: 280.0)
    
    var margin = 20.0
    
    var config: FocusPomodoroConfig {
        get {
            return circleView.config
        }
        
        set {
            circleView.config = newValue
            reloadData(animated: false)
        }
    }
    
    func setConfig(_ config: FocusPomodoroConfig, animated: Bool) {
        circleView.config = config
        reloadData(animated: animated)
    }
    
    /// 计时器发生改变
    var configDidChange: ((FocusPomodoroConfig) -> Void)?
    
    /// 当前编辑阶段
    var editPhase: FocusPomodoroPhase = .focus
    
    /// 番茄圆环视图
    let circleView: PomodoroCircleView = PomodoroCircleView()
    
    /// 分钟选择器
    lazy var durationPicker: TPCountPickerView = {
        let picker = TPCountPickerView(style: .backgroundColorCleared)
        picker.font = UIFont.boldSystemFont(ofSize: 32.0)
        picker.stepCount = 5 /// 间隔为5分钟
        picker.tailingLabel.textAlignment = .center
        picker.tailingTextForCount = { count in
            return resGetString("Minutes")
        }
        
        picker.didPickCount = { [weak self] count in
            self?.didPickMinutes(count)
        }
        
        return picker
    }()
    
    /// 每轮番茄数目选择视图
    lazy var countStepper: TPStepperView = {
        let stepper = TPStepperView()
        stepper.minimumValue = FocusPomodoroConfig.minimumPomosCountPerCircle
        stepper.maximumValue = FocusPomodoroConfig.maximumPomosCountPerCircle
        stepper.value = config.pomosCountPerCycle
        stepper.valueDidChange = { [weak self] value in
            self?.didSelectPomosCount(value)
        }
        
        stepper.didClickValue = { [weak self] sourceView in
            self?.didClickStepper(sourceView)
        }
        
        return stepper
    }()
    
    /// 番茄阶段菜单
    lazy var phaseMenuView: TPSegmentedMenuView = {
        let menuView = TPSegmentedMenuView()
        menuView.buttonHeight = 40.0
        menuView.minButtonWidth = 60.0
        menuView.padding = UIEdgeInsets(value: 4.0)
        menuView.buttonEdgeInsets = UIEdgeInsets(left: 15.0, right: 15.0)
        menuView.menuItems = FocusPomodoroPhase.segmentedMenuItems()
        menuView.didSelectMenuItem = { [weak self] menuItem in
            self?.didSelectMenuItem(menuItem)
        }
        
        return menuView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(circleView)
        circleView.addSubview(durationPicker)
        addSubview(countStepper)
        addSubview(phaseMenuView)
        updateDurationPicker()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData(animated: Bool) {
        circleView.reloadData(animated: animated)
        updateDurationPicker()
        countStepper.value = config.pomosCountPerCycle
        phaseMenuView.selectMenu(withTag: editPhase.rawValue)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleView.size = circleSize
        circleView.alignCenter()
        
        let circleLineWidth = circleView.circleWidth
        durationPicker.frame = circleView.bounds.insetBy(dx: circleLineWidth, dy: circleLineWidth)
        durationPicker.layer.cornerRadius = durationPicker.halfWidth

        /// Stepper
        countStepper.size = CGSize(width: 160.0, height: 40.0)
        countStepper.bottom = circleView.top - margin
        countStepper.alignHorizontalCenter()
        
        phaseMenuView.sizeToFit()
        phaseMenuView.bottom = bounds.height
        phaseMenuView.alignHorizontalCenter()
    }
    
    // MARK: - Edit Duration
    /// 更新时长选择器
    func updateDurationPicker() {
        var minimumDuration: TimeInterval
        var maximumDuration: TimeInterval
        var currentDuration: TimeInterval
        switch editPhase {
        case .focus:
            minimumDuration = FocusPomodoroConfig.minimumFocusDuration
            maximumDuration = FocusPomodoroConfig.maximumFocusDuration
            currentDuration = config.focusDuration
        case .shortBreak:
            minimumDuration = FocusPomodoroConfig.minimumShortBreakDuration
            maximumDuration = FocusPomodoroConfig.maximumShortBreakDuration
            currentDuration = config.shortBreakDuration
        case .longBreak:
            minimumDuration = FocusPomodoroConfig.minimumLongBreakDuration
            maximumDuration = FocusPomodoroConfig.maximumLongBreakDuration
            currentDuration = config.longBreakDuration
        }
        
        durationPicker.minimumCount = Int(minimumDuration) / SECONDS_PER_MINUTE
        durationPicker.maximumCount = Int(maximumDuration) / SECONDS_PER_MINUTE
        durationPicker.reloadData()
        durationPicker.selectCount(Int(currentDuration) / SECONDS_PER_MINUTE, animated: true)
    }
    
    func didPickMinutes(_ minutes: Int) {
        let duration = Double(minutes * SECONDS_PER_MINUTE)
        var shouldReload = false
        switch editPhase {
        case .focus:
            if config.focusDuration != duration {
                config.focusDuration = duration
                shouldReload = true
            }
            
        case .shortBreak:
            if config.shortBreakDuration != duration {
                config.shortBreakDuration = duration
                shouldReload = true
            }
            
        case .longBreak:
            if config.longBreakDuration != duration {
                config.longBreakDuration = duration
                shouldReload = true
            }
        }
        
        if shouldReload {
            circleView.reloadData(animated: true)
            configDidChange?(config)
        }
    }
    
    
    // MARK: - Edit pomos count
    private func didSelectPomosCount(_ count: Int) {
        TPImpactFeedback.impactWithLightStyle()
        
        if config.pomosCountPerCycle != count {
            config.pomosCountPerCycle = count
            circleView.reloadData(animated: true)
            configDidChange?(config)
        }
    }
    
    private func didClickStepper(_ sourceView: UIView) {
        TPImpactFeedback.impactWithLightStyle()
        
        let pickerVC = TPCountPickerViewController()
        pickerVC.minimumCount = FocusPomodoroConfig.minimumPomosCountPerCircle
        pickerVC.maximumCount = FocusPomodoroConfig.maximumPomosCountPerCircle
        pickerVC.count = config.pomosCountPerCycle
        pickerVC.didPickCount = { count in
            self.countStepper.value = count
            self.didSelectPomosCount(count)
        }
        
        pickerVC.popoverShow(from: sourceView,
                             sourceRect: sourceView.bounds,
                             isSourceViewCovered: false,
                             preferredPosition: .bottomCenter,
                             permittedPositions: [.topCenter, .bottomCenter],
                             animated: true,
                             completion: nil)
    }

    // MARK: - Menu
    private func didSelectMenuItem(_ menuItem: TPSegmentedMenuItem) {
        editPhase = FocusPomodoroPhase(rawValue: menuItem.tag) ?? .focus
        circleView.animte(for: editPhase)
        updateDurationPicker()
    }
}
