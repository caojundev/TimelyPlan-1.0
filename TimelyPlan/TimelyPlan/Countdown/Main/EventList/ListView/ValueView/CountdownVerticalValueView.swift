//
//  CountdownVerticalValueView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/16.
//

import Foundation
import UIKit

/// 倒计时数值视图：上方大数字，下方单位
class CountdownVerticalValueView: TPInfoView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleConfig.textAlignment = .right
        self.titleConfig.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        self.titleConfig.adjustsFontSizeToFitWidth = true
        
        self.subtitleConfig.adjustsFontSizeToFitWidth = true
        self.subtitleConfig.textAlignment = .right
        self.subtitleConfig.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        self.subtitleConfig.textColor = .primary
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 设置换算结果
    /// 上方为最大粒度的「数值 + 单位」，下方为第二个粒度的「数值 + 单位」（如 "13月" / "5天"）
    /// - Parameter result: 由 `CountdownCalculator.timeResult(...)` 换算得到的结果
    func setResult(_ result: CountdownCalculator.TimeResult) {
        self.title = result.primaryText
        self.subtitle = result.secondaryText
    }
}
