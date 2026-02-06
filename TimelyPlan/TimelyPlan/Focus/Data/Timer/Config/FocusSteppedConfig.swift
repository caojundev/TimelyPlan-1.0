//
//  SteppedTimerConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/23.
//

import Foundation
import UIKit

struct FocusTimerStep: Codable,
                        Hashable,
                        Equatable,
                       TPHexColorConvertible {
    
    static let colors = [Color(0x4A4DFF),
                         Color(0xFFB43E),
                         Color(0xF66464),
                         Color(0xD8451B),
                         Color(0x0C7B59),
                         Color(0x8F3986),
                         Color(0xCC7173),
                         Color(0xFFA14E),
                         Color(0x0BBDB8)]
    
    static var randomColor: UIColor {
        let index = Int(arc4random()) % colors.count
        return colors[index]
    }
    
    /// 默认专注颜色
    static var defaultColor = colors[0]
    
    /// 默认步骤时长
    static var defaultDuration: Duration = 5 * SECONDS_PER_MINUTE
    
    /// 唯一标识
    let identifier: String?
    
    /// 步骤名称
    var name: String?
    
    /// 颜色十六进制字符串
    var colorHex: String?
    
    /// 步骤模式
    var mode: FocusStepMode? = .focus
    
    /// 步骤时长
    var duration: Duration? = 5 * SECONDS_PER_MINUTE

    init() {
        self.identifier = UUID().uuidString
        self.color = Self.randomColor
    }
    
    /// 附加信息富文本
    var attributedInfo: ASAttributedString? {
        var infos = [ASAttributedString]()
        let mode = mode ?? .focus
        let duration = duration ?? Self.defaultDuration
        infos.append(.init(string: mode.title))
        infos.append(.init(string: duration.localizedTitle))
        return infos.joined(separator: " • ")
    }
}

struct FocusSteppedConfig: Hashable,
                            Equatable,
                            Codable,
                            FocusStepsProvider {
    /// 步骤数组
    var timerSteps: [FocusTimerStep]?

    var stepsCount: Int {
        return timerSteps?.count ?? 0
    }
    
    /// 步骤计时器描述信息
    var info: String {
        let count = self.timerSteps?.count ?? 0
        let format: String
        if count > 1 {
            format = resGetString("%ld steps")
        } else {
            format = resGetString("%ld step")
        }
        
        return String(format: format, count)
    }
    
    /// 添加步骤
    mutating func addStep(_ step: FocusTimerStep) {
        var steps = timerSteps ?? []
        steps.append(step)
        self.timerSteps = steps
    }
    
    /// 插入步骤
    mutating func insertStep(_ step: FocusTimerStep, at index: Int) {
        var steps = timerSteps ?? []
        guard index >= 0, index <= steps.count else {
            return
        }
        
        steps.insert(step, at: index)
        self.timerSteps = steps
    }
    
    /// 添加步骤
    mutating func deleteStep(_ step: FocusTimerStep) {
        guard var steps = timerSteps else {
            return
        }

        let _ = steps.remove(step)
        self.timerSteps = steps
    }
    
    /// 替换步骤
    mutating func replaceStep(_ oldStep: FocusTimerStep, with newStep: FocusTimerStep) {
        guard var steps = timerSteps else {
            return
        }
        
        guard let index = steps.firstIndex(of: oldStep) else {
            return
        }
        
        steps.replaceElement(at: index, with: newStep)
        self.timerSteps = steps
    }
    
    /// 移动步骤
    mutating func moveStep(fromIndex: Int, toIndex: Int) -> Bool {
        guard var steps = timerSteps else {
            return false
        }
        
        steps.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        self.timerSteps = steps
        return true
    }
    
    /// 是否可以添加新步骤
    func canAddNewStep() -> Bool {
        let maxStepCount: Int = 10
        return stepsCount < maxStepCount
    }
    
    // MARK: - FocusStepsProvider
    func steps() -> [FocusStep] {
        let autoStart = focus.setting.getSteppedAutoStartNext()
        var steps = [FocusStep]()
        let timerSteps = timerSteps ?? []
        for timerStep in timerSteps {
            var duration = timerStep.duration ?? FocusTimerStep.defaultDuration
            duration = max(SECONDS_PER_MINUTE, duration)
            var step = FocusStep(name: timerStep.name,
                                 mode: .focus,
                                 timerType: .countdown,
                                 duration: Double(duration),
                                 autoStart: autoStart)
            step.color = timerStep.color
            steps.append(step)
        }
        
        return steps
    }
}
