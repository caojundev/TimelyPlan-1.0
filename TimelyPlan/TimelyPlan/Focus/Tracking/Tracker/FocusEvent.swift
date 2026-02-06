//
//  FocusTimerEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/1.
//

import Foundation
import UIKit

enum FocusEventActionType: Int, CaseIterable {
    case start  /// 开始
    case pause  /// 暂停
    case resume /// 继续
    case next   /// 下一步
}
     
class FocusEvent: Codable {
    
    /// 专注事件状态
    enum State {
        case notStarted      /// 未开始
        case waitingForFocus /// 等待专注
        case waitingForBreak /// 等待休息
        case focusing        /// 正在专注
        case breaking        /// 正在休息
        case focusPaused     /// 专注暂停中
        case breakPaused     /// 休息暂停中
        case finished        /// 已结束
    }

    /// 事件唯一标识
    var identifier: String? = UUID().uuidString

    /// 事件步骤
    var steps: [FocusStep]?
    
    /// 专注任务信息
    var taskInfo: TaskInfo?
    
    /// 计时器特征属性
    var timerFeature: TimerFeature?
    
    /// 计时器配置信息
    var timerConfig: FocusTimerConfig?
    
    /// 是否可以暂停
    var canPause: Bool = true
     
    /// 可以暂停的次数上限
    var limitPauseTimes: Int?
    
    /// 当已经被暂停时表示暂停的具体时间，其它状态为nil
    private var pauseDate: Date?

    /// 该事件是否已经被暂停
    var isPaused: Bool {
        return pauseDate != nil
    }
    
    /// 事件开始日期
    var startDate: Date? {
        guard let step = steps?.first, step.isStarted else {
            return nil
        }
        
        return step.startDate
    }
    
    /// 事件结束日期
    var endDate: Date? {
        guard let lastStep = steps?.last else {
            return nil
        }
        
        return lastStep.endDate
    }
    
    /// 进行中的步骤
    var currentStep: FocusStep? {
        let date = pauseDate ?? .now
        let steps = steps ?? []
        for step in steps {
            if step.duration == 0.0 {
                /// 当前步骤的目标时长为0，查找下一步
                continue
            }
            
            guard let startDate = step.startDate, date >= startDate else {
                /// 该步骤未开始，返回该步骤
                return step
            }
            
            /// 当前日期在该步骤的
            if let endDate = step.endDate, date < endDate {
                return step
            }
        }
        
        return nil
    }
    
    /// 当前步骤开始结束日期范围
    var currentStepDateRange: DateRange? {
        guard isRunning,
              let step = currentStep,
              let startDate = step.startDate,
              let endDate = step.endDate else {
            return nil
        }
        
        return DateRange(startDate: startDate, endDate: endDate)
    }
    
    /// 当前步骤提醒日期
    var currentStepAlarmDate: Date? {
        guard isRunning,
              let step = currentStep,
              step.timerType != .stopwatch,
              let alarmDate = step.endDate else {
            return nil
        }
        
        return alarmDate
    }
    
    /// 是否运行中
    var isRunning: Bool {
        let state = state
        return state == .focusing || state == .breaking
    }
    
    /// 获取事件当前状态
    var state: FocusEvent.State {
        guard let currentStep = currentStep, currentStep.duration > 0.0 else {
            /// 当前步骤目标时长为0，表示当前指向步骤未开始，用户手动完成了所有步骤
            return .finished
        }
        
        return state(withCurrentStep: currentStep)
    }
    
    func state(withCurrentStep step: FocusStep) -> FocusEvent.State {
        guard let index = steps?.firstIndex(of: step) else {
            return .finished
        }
        
        let mode = step.mode 
        
        /// 未开始
        if !step.isStarted {
            if index == 0 {
                return .notStarted
            }
            
            /// 等待专注或休息
            if mode == .break {
                return .waitingForBreak
            } else {
                return .waitingForFocus
            }
        }
        
        /// 暂停中
        if isPaused {
            if mode == .break {
                return .breakPaused
            } else {
                return .focusPaused
            }
        }
        
        /// 休息进行中
        if mode == .break {
            return .breaking
        }
        
        /// 专注进行中
        return .focusing
    }
    
    /// 是否有下一步
    var hasNextStep: Bool {
        guard let step = currentStep else {
            return false
        }
        
        return hasNextStep(ofStep: step)
    }
    
    /// 判断特定步骤后是否有下一步骤
    func hasNextStep(ofStep step: FocusStep) -> Bool {
        guard let steps = steps, steps.count > 1, let index = steps.firstIndex(of: step) else {
            return false
        }

        return index + 1 < steps.count
    }
    
    /// 当前步骤已过总时长
    func elapsedDuration(ofStep step: FocusStep) -> TimeInterval {
        guard let startDate = step.startDate else {
            return 0.0
        }

        let date = pauseDate ?? .now
        var interval = date.timeIntervalSince(startDate)
        if let pauseInterval = step.pauses?.interval {
            interval -= pauseInterval
        }
        
        return min(step.duration, interval)
    }
    
    /// 当前步剩余时长
    func remainDuration(ofStep step: FocusStep) -> TimeInterval {
        guard let startDate = step.startDate else {
            /// 任务未开始，返回步骤目标时长
            return step.duration
        }
        
        let date = pauseDate ?? Date()
        let interval = date.timeIntervalSince(startDate)
        var totalInterval = step.duration
        if let pauseInteval = step.pauses?.interval {
            totalInterval += pauseInteval
        }
        
        let remain = totalInterval - interval
        return max(0.0, remain)
    }
}

// MARK: - 事件操作
extension FocusEvent {
    
    /// 开始当前步骤
    func start() {
        guard let step = currentStep else {
            return
        }
        
        if !step.isStarted {
            step.startDate = .now
        }
        
        updateNextSteps()
    }
    
    /// 当步骤自动开始是则开始当前步骤
    func startIfAutoStart() {
        guard let step = currentStep else {
            return
        }
        
        let autoStart = step.autoStart ?? false
        if autoStart && !step.isStarted {
            step.startDate = .now
        }
        
        updateNextSteps()
    }

    /// 暂停当前步骤
    func pause() {
        guard !isPaused, let step = currentStep, step.isStarted else {
            return
        }

        pauseDate = Date()
        updateNextSteps()
    }
    
    /// 继续
    func resume() {
        guard let pauseStartDate = pauseDate else {
            return
        }
        
        let pauseInterval = Date().timeIntervalSince(pauseStartDate)
        let pause = TimeFragment(startDate: pauseStartDate, interval: pauseInterval)
        if let currentStep = currentStep {
            var pauses = currentStep.pauses ?? []
            pauses.append(pause)
            currentStep.pauses = pauses
        }
        
        pauseDate = nil
        updateNextSteps()
    }
    
    /// 进入下一步
    func next() {
        completeCurrentStep()
        startIfAutoStart()
    }
    
    /// 完成所有步骤
    func completeAllStep() {
        guard let steps = steps,
                let step = currentStep,
                let index = steps.firstIndex(of: step) else {
            return
        }
        
        /// 完成当前步骤
        completeCurrentStep()
        
        /// 更新事件的步骤数组，丢弃后面未开始的步骤
        var toIndex = index
        if step.duration == 0.0 {
            /// 当前步骤未开始，索引指向前一步
            toIndex -= 1
        }
    
        self.steps = toIndex < 0 ? nil : Array(steps[0...toIndex])
    }

    /// 微调时长
    func adjustDuration(by increment: TimeInterval) {
        guard let step = currentStep else {
            return
        }
        
        let currentDuration = step.duration
        var newDuration = currentDuration + increment
        if increment < 0 {
            /// 缩短时长
            let remain = remainDuration(ofStep: step)
            if remain < -increment {
                /// 不可调整
                newDuration = currentDuration
            }
        }
        
        step.duration = newDuration
        updateNextSteps()
    }
    
    // MARK: - Private Methods
    /// 完成当前步骤
    private func completeCurrentStep() {
        guard let step = currentStep else {
            return
        }
 
        guard let startDate = step.startDate else {
            step.duration = 0.0
            return
        }
        
        if isPaused {
            resume()
        }
 
        var duration = Date().timeIntervalSince(startDate)
        if let pauseDuration = step.pauses?.interval {
            duration -= pauseDuration
        }
        
        step.duration = duration
    
        /// 清除后续步骤开始日期
        guard let nextSteps = nextSteps(of: step) else {
            return
        }
    
        for step in nextSteps {
            step.startDate = nil
        }
    }
    
    /// 更新后续步骤
    private func updateNextSteps() {
        guard let currentStep = currentStep, let nextSteps = nextSteps(of: currentStep) else {
            return
        }
    
        var previousEndDate = isPaused ? nil : currentStep.endDate
        for step in nextSteps {
            if let autoStart = step.autoStart, autoStart {
                step.startDate = previousEndDate
            } else {
                step.startDate = nil
            }
            
            previousEndDate = step.endDate
        }
        
        #warning("删除打印数据")
        var strings = [String]()
        for step in nextSteps {
            if let startDate = step.startDate, let endDate = step.endDate {
                strings.append("[\(startDate.timeString) -> \(endDate.timeString)]")
            } else {
                strings.append("[🈳️]")
            }
        }
        
        debugPrint(strings.joined(separator: " "))
    }
    
    /// 获取特定步骤的后续步骤数组
    private func nextSteps(of step: FocusStep) -> [FocusStep]? {
        guard let steps = steps, let currentIndex = steps.firstIndex(of: step) else {
            return nil
        }
        
        let fromIndex = currentIndex + 1
        return Array(steps[fromIndex...])
    }
    
    /*
    /// 是否可以微调时长
    func canAdjustDuration(by increment: TimeInterval) -> (canDecrease: Bool, canIncrease: Bool) {
        guard let step = currentStep else {
            return (false, false)
        }
        
        let increment = fabs(increment)
        
        /// 是否可以减小
        var canDecrease = true
        let remainDuration = remainDuration(ofStep: step)
        if remainDuration <= increment + TimeInterval(SECONDS_PER_MINUTE) {
            canDecrease = false
        }
  
        /// 是否可以增加
        var canIncrease = true
        let newDuration = step.targetDuration + increment
        if newDuration > TimeInterval(SECONDS_PER_DAY) {
            canIncrease = false
        }
        
        return (canDecrease, canIncrease)
    }
     */
}

// MARK: - 计时器快照信息
extension FocusEvent {
    
    func timerInfo() -> FocusTimerInfo {
        guard let step = currentStep else {
            /// 已结束
            return .finishedInfo
        }
        
        let elapsedDuration = elapsedDuration(ofStep: step)
        let stepIndex = steps?.firstIndex(of: step)
        let stepsCount = steps?.count
        let state = state(withCurrentStep: step)
        let info = FocusTimerInfo(step: step,
                                  state: state,
                                  stepIndex: stepIndex,
                                  stepsCount: stepsCount,
                                  elapsedDuration: elapsedDuration)
        return info
    }
    
    
}

extension FocusEvent {
    
    /// 专注完成数据条目
    func endDataItem(with minimumRecordDuration: Duration) -> FocusEndDataItem? {
        guard let steps = steps, let startDate = steps.first?.startDate else {
            return nil
        }
        
        let timer = timerFeature?.timer
        var focusRecords = [FocusRecord]()
        var breakRecords = [FocusRecord]()
        var endDate: Date = startDate
        for step in steps {
            guard let record = step.record(with: timer) else {
                continue
            }
            
            if step.mode == .focus {
                focusRecords.append(record)
            } else {
                breakRecords.append(record)
            }
            
            endDate = record.timeline.endDate
        }

        return FocusEndDataItem(startDate: startDate,
                                endDate: endDate,
                                focusRecords: focusRecords,
                                breakRecords: breakRecords,
                                minimumRecordDuration: minimumRecordDuration)
    }
}
