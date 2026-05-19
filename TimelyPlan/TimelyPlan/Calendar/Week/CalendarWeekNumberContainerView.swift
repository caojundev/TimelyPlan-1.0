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
        layoutStyle.rowsCount = 1
        layoutStyle.columsCount = 1
        layoutStyle.lineWidth = 0.5
        layoutStyle.fromRow = 1
        layoutStyle.fromColum = 1
        layoutStyle.lineColor = CalendarConstant.separatorColor
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
            self.backLayer.frame = bounds
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
