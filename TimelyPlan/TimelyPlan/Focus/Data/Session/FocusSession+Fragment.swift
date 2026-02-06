//
//  FocusSession+Fragment.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/14.
//

import Foundation

extension FocusSession {
    
    /// 按照开始日期排序的暂停对象
    var orderedPauses: [FocusPause]? {
        guard let pausesSet = self.pauses, let pausesArray = Array(pausesSet) as? [FocusPause] else {
            return nil
        }
        
        /// 删除开始日期为nil的暂停
        var validPauses = [FocusPause]()
        for pause in pausesArray {
            if pause.startDate != nil {
                validPauses.append(pause)
            }
        }
        
        let results = validPauses.sorted {
            return $0.startDate! < $1.startDate!
        }
        
        return results
    }
    
    /// 按日分类的专注有效时间段
    func validDailyFragments() -> [TimeFragment] {
        var fragments = [TimeFragment]()
        let validFragments = validFragments()
        for validFragment in validFragments {
            let dailyFragments = validFragment.dailyFragments()
            fragments.append(contentsOf: dailyFragments)
        }
        
        return fragments
    }
    
    /// 专注有效时间段
    func validFragments() -> [TimeFragment] {
        guard let startDate = startDate,
              let endDate = endDate else {
            return []
        }
        
        var fragments: [TimeFragment] = []
        var currentStartDate = startDate
        
        //检查是否存在专注中断
        if let orderedPauses = orderedPauses {
            for pause in orderedPauses {
                let pauseStartDate = pause.startDate!
                let interval = pauseStartDate.timeIntervalSince(currentStartDate)
                //有效专注片段的结束就是中断的开始
                let fragment = TimeFragment(startDate: currentStartDate, interval: interval)
                fragments.append(fragment)

                // 下一个有效片段的开始就是中断结束后
                currentStartDate = pauseStartDate.addingTimeInterval(TimeInterval(pause.duration))
            }
        }
        
        //添加最后一个有效片段，从最后一个中断到专注结束
        let lastInterval = endDate.timeIntervalSince(currentStartDate)
        let lastFragment = TimeFragment(startDate: currentStartDate, interval: lastInterval)
        fragments.append(lastFragment)
        return fragments
    }
}
