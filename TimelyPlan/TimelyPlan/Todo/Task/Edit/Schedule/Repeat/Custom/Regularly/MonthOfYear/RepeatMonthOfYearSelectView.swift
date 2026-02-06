//
//  RepeatMonthsSelectView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/21.
//

import Foundation
import UIKit

class RepeatMonthOfYearSelectView: UIView {
    
    /// 内容高度
    static var contentHeight: CGFloat {
        return buttonHeight * 3 + 2 * buttonMargin
    }
    
    /// 年中的月份数组（1 到 12）
    var monthsOfTheYear: [Int] = [] {
        didSet {
            updateButtonStatus()
        }
    }
    
    /// 选中月份回调
    var monthsOfTheYearChanged: (([Int]) -> Void)?
    
    private let itemsCountPerRow: Int = 4
    private static let buttonHeight = 44.0
    private static let buttonMargin = 1.0
    private var buttons: [TPDefaultButton] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        backgroundColor = Color(0x888888, 0.2)
        let monthSymbols = Date.monthSymbols
        for (index, monthSymbol) in monthSymbols.enumerated() {
            let button = TPDefaultButton()
            button.title = monthSymbol
            button.tag = index + 1
            button.preferredTappedScale = 1.0
            button.normalBackgroundColor = .secondarySystemGroupedBackground
            button.selectedBackgroundColor = Color(0x476AFF)
            button.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
            button.titleConfig.textColor = .secondaryLabel
            button.titleConfig.selectedTextColor = .white
            button.addTarget(self,
                             action: #selector(clickButton(_:)),
                             for: .touchUpInside)
            buttons.append(button)
            addSubview(button)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        let buttonWidth = (width - CGFloat(itemsCountPerRow - 1) * Self.buttonMargin) / CGFloat(itemsCountPerRow)
        for button in buttons {
            let index = button.tag - 1
            let row = index / itemsCountPerRow
            let col = index % itemsCountPerRow
            let x = CGFloat(col) * (buttonWidth + Self.buttonMargin)
            let y = CGFloat(row) * (Self.buttonHeight + Self.buttonMargin)
            button.frame = CGRect(x: x, y: y, width: buttonWidth, height: Self.buttonHeight)
        }
    }
    
    @objc private func clickButton(_ button: TPDefaultButton) {
        var bChanged = false
        let month = button.tag
        if monthsOfTheYear.contains(month) {
            if monthsOfTheYear.count > 1 {
                bChanged = true
                button.isSelected = false
                let _ = monthsOfTheYear.remove(month)
            }
        } else {
            bChanged = true
            button.isSelected = true
            monthsOfTheYear.append(month)
        }

        if bChanged {
            monthsOfTheYearChanged?(monthsOfTheYear)
        }
    }
    
    private func updateButtonStatus() {
        for button in buttons {
            button.isSelected = monthsOfTheYear.contains(button.tag)
        }
    }
}
