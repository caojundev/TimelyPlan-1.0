//
//  CountdownHorizontalValueView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/17.
//

import Foundation
import UIKit

/// 倒计时数值视图（左右布局：左侧大数字，右侧单位）
class CountdownHorizontalValueView: UIView {
    
    // MARK: 子视图
    let valueLabel = UILabel()
    let unitLabel = UILabel()
    
    /// 数值与单位的间距
    private let valueUnitMargin: CGFloat = 4.0
    
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
        
        valueLabel.font = UIFont.systemFont(ofSize: 32.0, weight: .bold)
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.5
        
        unitLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        unitLabel.adjustsFontSizeToFitWidth = true
        unitLabel.minimumScaleFactor = 0.5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = bounds.height
        let constraintSize = CGSize(width: bounds.width, height: height)
        
        /// 数字按内容宽度占位，单位紧随其后（数字过长时才压缩数字的可用宽度）
        let unitNaturalWidth = unitLabel.sizeThatFits(constraintSize).width
        let maximumValueWidth = max(0.0, bounds.width - unitNaturalWidth - valueUnitMargin)
        let valueWidth = min(valueLabel.sizeThatFits(constraintSize).width, maximumValueWidth)
        let unitWidth = min(unitNaturalWidth, max(0.0, bounds.width - valueWidth - valueUnitMargin))
        
        valueLabel.frame = CGRect(x: 0.0, y: 0.0, width: valueWidth, height: height)
        unitLabel.frame = CGRect(x: valueLabel.right + valueUnitMargin,
                                 y: 0.0,
                                 width: unitWidth,
                                 height: height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        /// 标签在宽度约束下的自适应尺寸
        let constraintSize = CGSize(width: size.width, height: .greatestFiniteMagnitude)
        let valueSize = valueLabel.sizeThatFits(constraintSize)
        let unitSize = unitLabel.sizeThatFits(constraintSize)
        
        let width = valueSize.width + valueUnitMargin + unitSize.width
        let height = max(valueSize.height, unitSize.height)
        
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
        setNeedsLayout()
    }
}
