//
//  CountdownDetailContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/22.
//

import Foundation
import UIKit

/// 倒数日详情内容视图
/// 负责标题、提示、目标日期与剩余时间的展示与布局
class CountdownDetailContentView: UIView {
    
    struct Config {
        /// 标题字号
        static let titleFont = UIFont.systemFont(ofSize: 28.0, weight: .bold)
        /// 提示字号
        static let tipFont = UIFont.systemFont(ofSize: 15.0, weight: .medium)
        /// 日期字号
        static let dateFont = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        /// 剩余时间区域与屏幕两侧最小间距
        static let daysHorizontalMargin: CGFloat = 24.0
        /// 标题 / 提示 / 日期行高
        static let titleHeight: CGFloat = 34.0
        static let tipHeight: CGFloat = 20.0
        static let dateHeight: CGFloat = 20.0
        /// 标题与提示、提示与剩余时间、剩余时间与日期之间的间距
        static let titleTipSpacing: CGFloat = 46.0
        static let tipDaysSpacing: CGFloat = 30.0
        static let daysDateSpacing: CGFloat = 10.0
    }
    
    // MARK: - 子视图
    /// 标题：表情 + 名称
    let titleLabel = UILabel()
    /// 提示：未到期为“距离目标还有”，已过期为“已经过去”
    let tipLabel = UILabel()
    
    /// 目标日期
    let dateLabel = UILabel()
    /// 剩余时间视图：通过 `result` 直接配置内容
    let daysLabel = CountdownTimeValueView()
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    // MARK: - 数据
    /// 应用倒数日事项，刷新标签内容与样式
    func apply(event: CountdownEvent) {
        /// 事件颜色：用于剩余时间的光晕
        let color = event.color ?? event.type.color
        
        titleLabel.text = "\(event.emoji ?? event.type.emoji) \(event.displayName)"
        dateLabel.text = event.occuranceDate.displayText
        
        let countingType = event.effectiveCountingType
        tipLabel.text = countingType == .countUp ? resGetString("Days Passed") : resGetString("Days Remaining")
        
        /// 剩余时间：由 CountdownCalculator 按事项的时间单位换算后配置
        daysLabel.result = event.remainingTimeResult
        daysLabel.glowColor = color
    }
    
    // MARK: - UI
    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(tipLabel)
        addSubview(dateLabel)
        addSubview(daysLabel)
        
        titleLabel.textColor = .white
        titleLabel.font = Config.titleFont
        titleLabel.textAlignment = .center
        
        tipLabel.textColor = .white
        tipLabel.font = Config.tipFont
        tipLabel.textAlignment = .center
        
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        dateLabel.font = Config.dateFont
        dateLabel.textAlignment = .center
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutLabels()
    }
    
    private func layoutLabels() {
        let width = bounds.width
        
        /// 剩余时间：整体垂直居中，左右保留间距，超出宽度由 adjustsFontSizeToFitWidth 缩放
        let daysHeight = daysLabel.textLineHeight
        let daysTop = bounds.midY - daysHeight / 2.0
        daysLabel.frame = CGRect(x: Config.daysHorizontalMargin,
                                 y: daysTop,
                                 width: max(0.0, width - Config.daysHorizontalMargin * 2.0),
                                 height: daysHeight)
        
        /// 提示：位于剩余时间上方
        tipLabel.frame = CGRect(x: 0.0,
                                y: daysTop - Config.tipDaysSpacing,
                                width: width,
                                height: Config.tipHeight)
        
        /// 标题：位于提示上方
        titleLabel.frame = CGRect(x: 0.0,
                                  y: tipLabel.frame.minY - Config.titleTipSpacing,
                                  width: width,
                                  height: Config.titleHeight)
        
        /// 日期：位于剩余时间下方
        dateLabel.frame = CGRect(x: 0.0,
                                 y: daysLabel.frame.maxY + Config.daysDateSpacing,
                                 width: width,
                                 height: Config.dateHeight)
    }
}

// MARK: - 剩余时间视图
/// 倒数日剩余时间视图
/// 封装「数值大字号 + 单位小字号角标」的富文本拼装与光晕样式，通过 `result` 直接配置内容
class CountdownTimeValueView: UILabel {
    
    struct Config {
        /// 数值默认字号
        static let valueFontSize: CGFloat = 80.0
        /// 单位默认字号
        static let unitFontSize: CGFloat = 20.0
        /// 数值宽度不足时的最小缩放比例
        static let minimumScaleFactor: CGFloat = 0.34
        /// 光晕半径与初始透明度
        static let glowRadius: CGFloat = 20.0
        static let glowOpacity: Float = 0.5
    }
    
    /// 数值字体（宽度不足时由 adjustsFontSizeToFitWidth 缩放）
    var valueFont: UIFont = .monospacedDigitSystemFont(ofSize: Config.valueFontSize, weight: .black) {
        didSet {
            updateText()
        }
    }
    
    /// 单位字体
    var unitFont: UIFont = .systemFont(ofSize: Config.unitFontSize, weight: .medium) {
        didSet {
            updateText()
        }
    }
    
    /// 单行文本高度（供外部布局使用）
    var textLineHeight: CGFloat {
        return ceil(valueFont.lineHeight)
    }
    
    /// 单位文本颜色
    var unitColor: UIColor = UIColor.white.withAlphaComponent(0.8) {
        didSet {
            updateText()
        }
    }
    
    /// 光晕颜色（一般取事件颜色）
    var glowColor: UIColor = .white {
        didSet {
            layer.shadowColor = glowColor.cgColor
        }
    }
    
    /// 换算结果：配置后即刷新显示内容
    var result: CountdownCalculator.TimeResult? {
        didSet {
            updateText()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }
    
    // MARK: - 样式
    private func setupStyle() {
        textColor = .white
        textAlignment = .center
        numberOfLines = 1
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = Config.minimumScaleFactor
        layer.shadowRadius = Config.glowRadius
        layer.shadowOpacity = Config.glowOpacity
        layer.shadowOffset = .zero
    }
    
    // MARK: - 内容
    /// 刷新富文本内容（每个粒度以「数值大字号 + 单位小字号角标」拼接，同一基线）
    private func updateText() {
        guard let result = result else {
            attributedText = nil
            return
        }
        
        /// 组成部分：主数值 + 主单位，以及存在时的次数值 + 次单位
        var parts: [(value: String, unit: String)] = [(result.primaryValueText, result.primaryUnitText)]
        if let secondaryValueText = result.secondaryValueText,
           let secondaryUnitText = result.secondaryUnitText {
            parts.append((secondaryValueText, secondaryUnitText))
        }
        
        /// 数值颜色取标签自身的 `textColor`，单位颜色由 `unitColor` 单独控制
        let valueAttributes: [NSAttributedString.Key: Any] = [.font: valueFont,
                                                             .foregroundColor: textColor ?? .white]
        let unitAttributes: [NSAttributedString.Key: Any] = [.font: unitFont,
                                                            .foregroundColor: unitColor]
        
        let text = NSMutableAttributedString()
        for (index, part) in parts.enumerated() {
            /// 组成部分之间留出间隔
            if index > 0 {
                text.append(NSAttributedString(string: " ", attributes: valueAttributes))
            }
            
            text.append(NSAttributedString(string: part.value, attributes: valueAttributes))
            text.append(NSAttributedString(string: part.unit, attributes: unitAttributes))
        }
        
        attributedText = text
    }
}
