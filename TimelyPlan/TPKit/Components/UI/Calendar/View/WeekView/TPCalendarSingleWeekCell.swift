//
//  TPCalendarSingleWeekCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/28.
//

import Foundation
import UIKit

class TPCalendarSingleWeekCell: TPCollectionCell {
    
    /// 周符号视图
    var symbolsViewHeight = 30.0
    
    private(set) lazy var symbolsView: TPWeekdaySymbolView = {
        return TPWeekdaySymbolView(frame: .zero)
    }()

    private(set) lazy var weekView: TPCalendarSingleWeekView = {
        return TPCalendarSingleWeekView(frame: bounds)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(symbolsView)
        contentView.addSubview(weekView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        symbolsView.width = bounds.width
        symbolsView.height = symbolsViewHeight
        
        weekView.width = bounds.width
        weekView.height = bounds.height - symbolsViewHeight
        weekView.top = symbolsViewHeight
    }
}
