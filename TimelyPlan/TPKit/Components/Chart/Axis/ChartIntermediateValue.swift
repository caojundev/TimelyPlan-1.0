//
//  ChartIntermediateValue.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/30.
//

import Foundation

class ChartIntermediateValue {
    
    /// 配置信息
    struct Config {
        
        /// 最小数值
        var minValue: CGFloat = 0.0
        
        /// 最大数值
        var maxValue: CGFloat
        
        /// 最小插值数目
        var minNumberOfValues: Int = 0
        
        /// 最大插值数目
        var maxNumberOfValues: Int = 3
        
        /// 最小间隔
        var minInterval: CGFloat = 1.0
    }
    
    /// 中间值结果信息
    struct Result {

        /// 中间数值
        var values: [CGFloat]?
        
        /// 最大值
        var maxValue: CGFloat
    }
    
    /// 根据配置获取中间值结果
    static func result(with maxValue: CGFloat) -> Result {
        let config = ChartIntermediateValue.Config(maxValue: maxValue)
        return result(with: config)
    }
    
    static func result(with config: Config) -> Result {
        guard config.maxNumberOfValues > 0 else {
            return Result(values: nil, maxValue: config.maxValue)
        }
        
        var numberOfValues = config.maxNumberOfValues
        var interval = (config.maxValue - config.minValue) / CGFloat(numberOfValues + 1)
        while numberOfValues > config.minNumberOfValues && interval < config.minInterval {
            numberOfValues -= 1
            interval = (config.maxValue - config.minValue) / CGFloat(numberOfValues + 1)
        }
        
        guard numberOfValues > 0,
                interval >= config.minInterval,
                numberOfValues >= config.minNumberOfValues else {
            return Result(values: nil, maxValue: config.maxValue)
        }
  
        let newInterval = ceilInterval(Int(ceil(interval)))
        let newMaxValue = config.minValue + CGFloat(newInterval * (numberOfValues + 1))
        var intermediateValues: [CGFloat] = []
        for index in 1...numberOfValues {
            let interpolatedValue = config.minValue + CGFloat(newInterval * index)
            intermediateValues.append(interpolatedValue)
        }

        return Result(values: intermediateValues, maxValue: newMaxValue)
    }
    
    /// 向上取整
    static func ceilInterval(_ value: Int) -> Int {
        var multiplier: Int
        if value <= 10 {
            return value
        } else if value <= 100 {
            /// 向上取值为5的整数倍
            multiplier = 5
        } else {
            multiplier = Int(pow(10.0, Double(value.digitsCount - 2)))
        }
        
        let remainder = value % multiplier
        if remainder == 0 {
            return value
        } else {
            return (value / multiplier + 1) * multiplier
        }
    }
}
