//
//  CalendarWeekNumberContainerView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/12.
//

import Foundation
import UIKit

class CalendarWeekNumberContainerView: UIView {
    
    var weekNumber: Int = 0 {
        didSet {
            numberView.weekNumber = weekNumber
        }
    }
    
    var numberView = CalendarWeekNumberView()
    
    private let backLayer = TPGridsLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        var layoutStyle = TPGridsLayoutStyle()
        layoutStyle.rowsCount = 1
        layoutStyle.columsCount = 1
        layoutStyle.lineWidth = 0.5
        layoutStyle.fromRow = 1
        layoutStyle.fromColum = 1
        layoutStyle.lineColor = CalendarWeekConstant.separatorColor
        backLayer.layoutStyle = layoutStyle
        layer.addSublayer(backLayer)
        
        numberView.weekNumber = weekNumber
        numberView.backgroundColor = .clear
        addSubview(numberView)
        backgroundColor = .systemBackground
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        executeWithoutAnimation {
            self.backLayer.frame = bounds
        }
        
        numberView.size = CGSize(width: 24.0, height: 32.0)
        numberView.alignCenter()
    }
    
}
