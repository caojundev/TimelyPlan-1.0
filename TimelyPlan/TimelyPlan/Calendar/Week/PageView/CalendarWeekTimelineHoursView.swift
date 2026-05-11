//
//  CalendarWeekTimelineHoursView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/13.
//

import Foundation
import UIKit

class CalendarWeekTimelineHoursView: CalendarDayTimelineHoursView {

    var allDayHeight: CGFloat = 0.0 {
        didSet {
            if allDayHeight != oldValue {
                layoutAllDayView()
                updateContentInset()
            }
        }
    }
    
    // 右侧分割线颜色
    var rightDividerColor: UIColor = Color(light: 0x000000, dark: 0xFFFFFF, alpha: 0.2) {
        didSet {
            rightDividerLayer.backgroundColor = rightDividerColor.cgColor
        }
    }
    
    // 右侧分割线宽度
    var rightDividerWidth: CGFloat = 0.4 {
        didSet {
            setNeedsLayout()
        }
    }
    
    // 右侧分割线
    private let rightDividerLayer = CALayer()
    
    private let allDayView = CalendarWeekTimelineHoursAllDayView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.addSublayer(rightDividerLayer)
        allDayView.backgroundColor = .systemGray5
        addSubview(allDayView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutAllDayView()

        rightDividerLayer.backgroundColor = rightDividerColor.cgColor
        rightDividerLayer.frame = CGRect(x: width - rightDividerWidth,
                                         y: 0.0,
                                         width: rightDividerWidth,
                                         height: contentView.contentSize.height - bottomPadding)
        rightDividerLayer.backgroundColor = rightDividerColor.cgColor
    }
    
    private func layoutAllDayView() {
        allDayView.width = width
        allDayView.height = allDayHeight
    }
    
    private func updateContentInset() {
        contentView.contentInset = UIEdgeInsets(top: allDayHeight)
    }
}


class CalendarWeekTimelineHoursAllDayView: UIView {
    
    private let textLabelHeight = 20.0
    private let textLabel: UILabel = {
        let label = TPLabel()
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.padding = UIEdgeInsets(horizontal: 4.0)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.adjustsFontSizeToFitWidth = true
        label.text = resGetString("All-Day")
        return label
    }()
    
    private let backLayer: TPGridsLayer = {
        var style = TPGridsLayoutStyle()
        style.columsCount = 1
        style.fromColum = 1
        style.toColum = 1
        style.rowsCount = 1
        style.fromRow = 1
        style.toRow = 1
        style.lineWidth = 0.4
        style.lineColor = Color(light: 0x000000, dark: 0xFFFFFF, alpha: 0.2)
        
        let backLayer = TPGridsLayer()
        backLayer.layoutStyle = style
        return backLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        clipsToBounds = true
        backgroundColor = .systemGray5
        layer.addSublayer(backLayer)
        addSubview(textLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backLayer.updateColors()
        textLabel.width = width
        textLabel.height = textLabelHeight
        textLabel.origin = .zero
        executeWithoutAnimation {
            self.backLayer.frame = bounds
        }
    }
}
