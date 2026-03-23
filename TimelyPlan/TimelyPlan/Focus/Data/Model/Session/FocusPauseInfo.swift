//
//  FocusPauseInfo.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/23.
//

import Foundation

public class FocusPauseInfo: NSObject, NSCopying, Codable {
    
    /// 时间切片
    struct Pause: Hashable, Codable, Equatable {
        
        /// 开始日期
        var startDate: Date?
        
        /// 时长
        var interval: TimeInterval?
    }

    /// 暂停时间切片
    var pauses: [Pause]?
    
    /// 暂停数目
    var count: Int {
        return pauses?.count ?? 0
    }
    
    /// 按照开始日期排序的暂停
    var orderedPauses: [Pause]? {
        guard let pauses = pauses else {
            return nil
        }
        
        /// 删除开始日期为nil的暂停
        var validPauses = [Pause]()
        for pause in pauses {
            if pause.startDate != nil, pause.interval != nil {
                validPauses.append(pause)
            }
        }
        
        return validPauses.sorted { $0.startDate! < $1.startDate! }
    }
    
    var fragments: [TimeFragment]? {
        guard let orderedPauses = orderedPauses else {
            return nil
        }

        var results = [TimeFragment]()
        for pause in orderedPauses {
            let fragment = TimeFragment(startDate: pause.startDate!,
                                        interval: pause.interval!)
            results.append(fragment)
        }
        
        return results
    }
    
    convenience init(pauseFragments: [TimeFragment]) {
        self.init()
        var pauses = [Pause]()
        for fragment in pauseFragments {
            let pause = Pause(startDate: fragment.startDate, interval: fragment.interval)
            pauses.append(pause)
        }
        
        self.pauses = pauses
    }
    
    // MARK: - 等同性判断
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(pauses)
        return hasher.finalize()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? FocusPauseInfo else { return false }
        if self === other { return true }
        return pauses == other.pauses
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = FocusPauseInfo()
        copy.pauses = pauses
        return copy
    }
    
    /*
    /// 根据开始结束日期，获取对应的时间切片
    func timeFragments(startDate: Date, endDate: Date) -> [TimeFragment] {
        var fragments: [TimeFragment] = []
        var currentStartDate = startDate
        
        // 检查是否存在专注中断
        if let orderedPauses = orderedPauses {
            for pause in orderedPauses {
                let pauseStartDate = pause.startDate!
                let interval = pauseStartDate.timeIntervalSince(currentStartDate)
                //有效专注片段的结束就是中断的开始
                let fragment = TimeFragment(startDate: currentStartDate, interval: interval)
                fragments.append(fragment)
                
                // 下一个有效片段的开始就是中断结束后
                currentStartDate = pauseStartDate.addingTimeInterval(pause.interval ?? 0)
            }
        }
        
        /// 添加最后一个有效片段，从最后一个中断到专注结束
        let lastInterval = endDate.timeIntervalSince(currentStartDate)
        let lastFragment = TimeFragment(startDate: currentStartDate, interval: lastInterval)
        fragments.append(lastFragment)
        return fragments
    }
     */
}
