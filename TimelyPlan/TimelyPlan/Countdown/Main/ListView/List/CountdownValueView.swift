//
//  CountdownValueView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/16.
//

import Foundation
import UIKit

/// 倒计时数值视图：上方大数字，下方单位
class CountdownValueView: UIView {
    
    // MARK: 子视图
    let valueLabel = UILabel()
    let unitLabel = UILabel()
    
    // MARK: 布局比例
    /// 数值高度占比
    private let valueHeightRatio: CGFloat = 0.7
    
    /// 单位高度占比
    private let unitHeightRatio: CGFloat = 0.3
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        addSubview(valueLabel)
        addSubview(unitLabel)
        valueLabel.textAlignment = .center
        valueLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        valueLabel.adjustsFontSizeToFitWidth = true
        
        
        unitLabel.adjustsFontSizeToFitWidth = true
        unitLabel.textAlignment = .center
        unitLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        let h = bounds.height
        
        let valueHeight = h * valueHeightRatio
        let unitHeight = h * unitHeightRatio
        
        valueLabel.frame = CGRect(x: 0, y: 0, width: w, height: valueHeight)
        unitLabel.frame = CGRect(x: 0, y: valueHeight, width: w, height: unitHeight)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        /// 标签在宽度约束下的自适应尺寸
        let constraintSize = CGSize(width: size.width, height: .greatestFiniteMagnitude)
        let valueSize = valueLabel.sizeThatFits(constraintSize)
        let unitSize = unitLabel.sizeThatFits(constraintSize)
        
        let width = max(valueSize.width, unitSize.width)
        /// 高度由数值 / 单位各自所占比例反推，取较大值以保证两者都能完整显示
        let height = max(valueSize.height / valueHeightRatio,
                         unitSize.height / unitHeightRatio)
        
        return CGSize(width: min(ceil(width), size.width),
                      height: min(ceil(height), size.height))
    }
    
    /// 设置数值和单位
    /// - Parameters:
    ///   - number: 数字
    ///   - unit: 单位文本，如 "天"、"周"、"月"、"年"
    func setValue(number: Int, unit: String) {
        valueLabel.text = "\(number)"
        unitLabel.text = unit
    }
}
