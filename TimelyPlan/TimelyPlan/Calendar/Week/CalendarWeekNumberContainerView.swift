//
//  CalendarWeekNumberContainerView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/12.
//

import Foundation
import UIKit

class CalendarWeekNumberContainerView: UIView {
    
    var showWeekNumber: Bool = false {
        didSet {
            if showWeekNumber != oldValue {
                setupWeekNumberView()
            }
        }
    }
    
    var weekNumber: Int = 0 {
        didSet {
            weekNumberView?.weekNumber = weekNumber
        }
    }
    
    private let weekNumberSize = CGSize(width: 24.0, height: 32.0)
    private let weekNumberHeight = 20.0
    private var weekNumberView: CalendarWeekNumberView?
    
    var layoutStyle: TPGridsLayoutStyle {
        didSet {
            backLayer.layoutStyle = layoutStyle
        }
    }
    
    private let backLayer = TPGridsLayer()
    
    override init(frame: CGRect) {
        var layoutStyle = TPGridsLayoutStyle()
        layoutStyle.lineWidth = CalendarConstant.separatorLineWidth
        layoutStyle.horizontalLineColor = CalendarConstant.horizontalSeparatorColor
        layoutStyle.verticalLineColor = CalendarConstant.verticalSeparatorColor
        layoutStyle.rowsCount = 1
        layoutStyle.fromRow = 1
        layoutStyle.columsCount = 1
        layoutStyle.fromColum = 1
        self.layoutStyle = layoutStyle
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        backgroundColor = .systemBackground
        backLayer.layoutStyle = layoutStyle
        layer.addSublayer(backLayer)
        setupWeekNumberView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        executeWithoutAnimation {
            let padding = UIEdgeInsets(value: CalendarConstant.separatorLineWidth / 2.0)
            self.backLayer.frame = bounds.inset(by: padding)
            self.backLayer.updateColors()
        }
        
        layoutWeekNumberView()
    }
    
    private func layoutWeekNumberView() {
        if let weekNumberView = weekNumberView {
            weekNumberView.size = weekNumberSize
            weekNumberView.alignCenter()
        }
    }
    
    private func setupWeekNumberView() {
        guard showWeekNumber else {
            weekNumberView?.removeFromSuperview()
            weekNumberView = nil
            return
        }
        
        let weekNumberView = CalendarWeekNumberView()
        weekNumberView.numberHeight = weekNumberHeight
        weekNumberView.weekNumber = weekNumber
        self.weekNumberView = weekNumberView
        addSubview(weekNumberView)
        setNeedsLayout()
    }
    
}
