//
//  CalendarYearHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/3.
//

import Foundation
import UIKit

class CalendarYearHeaderView: UICollectionReusableView {
    private let yearLabel = UILabel()
    private let chineseYearIndicator = CalendarLunarFirstIndicator()
    private let firstDayIndicator = CalendarLunarFirstIndicator()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutLabels()
    }
    
    private func setupUI() {
        // 年份标签（左侧）
        yearLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        yearLabel.textColor = .label
        addSubview(yearLabel)
        
        // 农历年份标签
        chineseYearIndicator.lineHeight = CalendarYearConfig.lunarNewYearLineHeight
        chineseYearIndicator.lineColor = CalendarYearConfig.lunarFirstLineColor
        chineseYearIndicator.font = .systemFont(ofSize: 10)
        chineseYearIndicator.textColor = .secondaryLabel
        addSubview(chineseYearIndicator)
        
        // 农历初一标签
        firstDayIndicator.lineHeight = CalendarYearConfig.lunarFirstDayLineHeight
        firstDayIndicator.lineColor = CalendarYearConfig.lunarFirstLineColor
        firstDayIndicator.font = .systemFont(ofSize: 10)
        firstDayIndicator.textColor = .secondaryLabel
        firstDayIndicator.title = "农历初一"
        addSubview(firstDayIndicator)
    }
    
    func configure(year: Int) {
        yearLabel.text = "\(year)"
        chineseYearIndicator.title = LunarCalendar.getChineseYearDescription(year: year)
        setNeedsLayout()
    }
    
    private func layoutLabels() {
        let margin: CGFloat = 16
        let layoutFrame = bounds.inset(by: UIEdgeInsets(horizontal: 16.0))
        // 年份标签（左侧）
        yearLabel.sizeToFit()
        yearLabel.frame = CGRect(
            x: margin,
            y: (bounds.height - yearLabel.bounds.height) / 2,
            width: yearLabel.bounds.width,
            height: yearLabel.bounds.height
        )
        
        // 农历初一标签（右下）
        firstDayIndicator.sizeToFit()
        firstDayIndicator.right = layoutFrame.maxX
        firstDayIndicator.top = layoutFrame.midY
        
        // 农历年份标签（右上，粗体）
        chineseYearIndicator.sizeToFit()
        chineseYearIndicator.right = layoutFrame.maxX
        chineseYearIndicator.bottom = layoutFrame.midY
    }
}

class CalendarLunarFirstIndicator: UIView {
    
    var lineHeight = 1.6 {
        didSet { setNeedsLayout() }
    }
    
    var lineColor: UIColor = .systemRed {
        didSet { lineView.backgroundColor = lineColor }
    }
    
    var title: String? {
        get { return textLabel.text }
        set { textLabel.text = newValue }
    }
    
    var font: UIFont {
        get { return textLabel.font }
        set { textLabel.font = newValue }
    }
    
    var textColor: UIColor {
        get { return textLabel.textColor }
        set { textLabel.textColor = newValue }
    }
    
    private let lineWidth = 10.0
    
    private let lineView = UIView()

    private let textLabel = TPLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        padding = UIEdgeInsets(vertical: 2.0)
        lineView.backgroundColor = lineColor
        addSubview(lineView)
        
        textLabel.textColor = .label
        textLabel.font = .boldSystemFont(ofSize: 10.0)
        textLabel.textAlignment = .left
        textLabel.edgeInsets = UIEdgeInsets(left: 5.0)
        addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        
        lineView.width = lineWidth
        lineView.height = lineHeight
        lineView.left = layoutFrame.minX
        lineView.alignVerticalCenter()
        
        textLabel.width = layoutFrame.width - lineWidth
        textLabel.height = layoutFrame.height
        textLabel.left = lineView.right
        textLabel.top = layoutFrame.minY
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = textLabel.sizeThatFits(.unlimited)
        size.width = size.width + lineWidth + padding.horizontalLength
        size.height = size.height + padding.verticalLength
        return size
    }
    
}
