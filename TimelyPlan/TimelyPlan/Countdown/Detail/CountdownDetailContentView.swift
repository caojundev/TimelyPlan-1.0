//
//  CountdownDetailContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/22.
//

import Foundation
import UIKit

/// 倒数日详情内容视图
/// 负责标题、提示、目标日期与天数的展示、布局与光晕动画
class CountdownDetailContentView: UIView {
    
    struct Config {
        /// 标题字号
        static let titleFont = UIFont.systemFont(ofSize: 28.0, weight: .bold)
        /// 提示字号
        static let tipFont = UIFont.systemFont(ofSize: 15.0, weight: .medium)
        /// 日期字号
        static let dateFont = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        /// 天数默认字号
        static let daysFontSize: CGFloat = 120.0
        /// 天数单位字号
        static let daysUnitFont = UIFont.systemFont(ofSize: 20.0, weight: .medium)
        /// 天数区域与屏幕两侧最小间距
        static let daysHorizontalMargin: CGFloat = 24.0
        /// 天数自适应最小缩放比例
        static let daysMinimumScaleFactor: CGFloat = 0.34
        /// 天数光晕半径与初始透明度
        static let daysGlowRadius: CGFloat = 20.0
        static let daysGlowOpacity: Float = 0.5
        /// 天数光晕呼吸动画的透明度范围
        static let daysGlowMinOpacity: CGFloat = 0.3
        static let daysGlowMaxOpacity: CGFloat = 0.7
        /// 天数光晕呼吸周期
        static let daysGlowAnimationDuration: CFTimeInterval = 1.5
        /// 标题 / 提示 / 日期行高
        static let titleHeight: CGFloat = 34.0
        static let tipHeight: CGFloat = 20.0
        static let dateHeight: CGFloat = 20.0
        /// 标题与提示、提示与天数、天数与日期之间的间距
        static let titleTipSpacing: CGFloat = 46.0
        static let tipDaysSpacing: CGFloat = 30.0
        static let daysDateSpacing: CGFloat = 10.0
    }
    
    /// 动画键
    private enum AnimationKey {
        static let daysGlow = "daysGlowPulse"
    }
    
    // MARK: - 数据
    /// 天数基础字体（宽度不足时由 adjustsFontSizeToFitWidth 缩放）
    private let daysBaseFont = UIFont.monospacedDigitSystemFont(ofSize: Config.daysFontSize,
                                                              weight: .black)
    
    // MARK: - 子视图
    /// 标题：表情 + 名称
    let titleLabel = UILabel()
    /// 提示：未到期为“距离目标还有”，已过期为“已经过去”
    let tipLabel = UILabel()
    /// 目标日期
    let dateLabel = UILabel()
    /// 天数：数值 + 单位富文本
    let daysLabel = UILabel()
    
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
        /// 事件颜色：用于天数光晕与单位文本
        let color = event.color ?? event.type.color
        
        titleLabel.text = "\(event.emoji ?? event.type.emoji) \(event.displayName)"
        tipLabel.text = event.isExpired ? resGetString("Days Passed") : resGetString("Days Remaining")
        dateLabel.text = event.occuranceDate.displayText
        
        /// 天数：数值 + 单位组合为富文本，宽度不足时自动缩小字号
        daysLabel.attributedText = daysText(days: abs(event.remainingDays), unitColor: color)
        daysLabel.layer.shadowColor = color.cgColor
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
        
        daysLabel.textAlignment = .center
        daysLabel.numberOfLines = 1
        daysLabel.adjustsFontSizeToFitWidth = true
        daysLabel.minimumScaleFactor = Config.daysMinimumScaleFactor
        daysLabel.layer.shadowRadius = Config.daysGlowRadius
        daysLabel.layer.shadowOpacity = Config.daysGlowOpacity
        daysLabel.layer.shadowOffset = .zero
    }
    
    /// 天数文本（数值大字号 + 单位小字号，同一基线）
    private func daysText(days: Int, unitColor: UIColor) -> NSAttributedString {
        let text = NSMutableAttributedString(string: "\(days)",
                                             attributes: [.font: daysBaseFont,
                                                          .foregroundColor: UIColor.white])
        let unit = " " + resGetString(days == 1 ? "Day" : "Days")
        text.append(NSAttributedString(string: unit,
                                       attributes: [.font: Config.daysUnitFont,
                                                    .foregroundColor: unitColor.withAlphaComponent(0.8)]))
        return text
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutLabels()
    }
    
    private func layoutLabels() {
        let width = bounds.width
        
        /// 天数：整体垂直居中，左右保留间距，超出宽度由 adjustsFontSizeToFitWidth 缩放
        let daysHeight = ceil(daysBaseFont.lineHeight)
        let daysTop = bounds.midY - daysHeight / 2.0
        daysLabel.frame = CGRect(x: Config.daysHorizontalMargin,
                                 y: daysTop,
                                 width: max(0.0, width - Config.daysHorizontalMargin * 2.0),
                                 height: daysHeight)
        
        /// 提示：位于天数上方
        tipLabel.frame = CGRect(x: 0.0,
                                y: daysTop - Config.tipDaysSpacing,
                                width: width,
                                height: Config.tipHeight)
        
        /// 标题：位于提示上方
        titleLabel.frame = CGRect(x: 0.0,
                                  y: tipLabel.frame.minY - Config.titleTipSpacing,
                                  width: width,
                                  height: Config.titleHeight)
        
        /// 日期：位于天数下方
        dateLabel.frame = CGRect(x: 0.0,
                                 y: daysLabel.frame.maxY + Config.daysDateSpacing,
                                 width: width,
                                 height: Config.dateHeight)
    }
    
    // MARK: - 动画
    /// 天数光晕呼吸动画
    func startDaysGlowPulse(delay: TimeInterval = 0.0) {
        daysLabel.layer.removeAnimation(forKey: AnimationKey.daysGlow)
        
        let pulse = CABasicAnimation(keyPath: "shadowOpacity")
        pulse.fromValue = Config.daysGlowMinOpacity
        pulse.toValue = Config.daysGlowMaxOpacity
        pulse.duration = Config.daysGlowAnimationDuration
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.beginTime = CACurrentMediaTime() + delay
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        daysLabel.layer.add(pulse, forKey: AnimationKey.daysGlow)
    }
}
