//
//  ChartAxisLabel.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/29.
//

import Foundation
import UIKit

/// 图表标签标记
struct ChartAxisLabelMark {
    
    /// 轴标签对应的数值
    var value: CGFloat
    
    /// 轴标签文本
    var text: String?
    
    /// 整型tag
    var tag: Int = 0
    
    init(value: CGFloat, text: String?) {
        self.value = value
        self.text = text
    }
    
    init(value: Int, text: String?) {
        self.init(value: CGFloat(value), text: text)
    }
    
    /// 生成一个给定范围内的标签标记数组
    static func marks(fromValue: Int, toValue: Int, step: Int) -> [ChartAxisLabelMark] {
        var labelMarks: [ChartAxisLabelMark] = []
        var value = fromValue
        while value <= toValue {
            let text = "\(value)"
            let mark = ChartAxisLabelMark(value: value, text: text)
            labelMarks.append(mark)
            value += step
        }
        
        return labelMarks
    }
}

struct ChartAxisLabelStyle {
    
    /// 字体
    var font = UIFont.boldSystemFont(ofSize: 12.0)
    
    /// 颜色
    var textColor: UIColor = Color(0x888888, 0.6)
    
    /// 文本行数目
    var numberOfLines: Int = 0
    
    /// 对齐方式
    var textAlignment: NSTextAlignment = .center
}

class ChartAxisLabel: TPLabel {
    
    /// 标记
    var mark: ChartAxisLabelMark
    
    /// 样式
    var style = ChartAxisLabelStyle() {
        didSet {
            setNeedsLayout()
        }
    }
    
    convenience init(mark: ChartAxisLabelMark) {
        self.init(frame: .zero, mark: mark)
    }
    
    init(frame: CGRect, mark: ChartAxisLabelMark) {
        self.mark = mark
        super.init(frame: frame)
        self.text = mark.text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.font = style.font
        self.textColor = style.textColor
        self.numberOfLines = style.numberOfLines
        self.textAlignment = style.textAlignment
    }
}
