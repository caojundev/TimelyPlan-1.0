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
    var symbolsViewHeight = 20.0
    
    private(set) lazy var symbolsView: TPWeekdaySymbolView = {
        return TPWeekdaySymbolView(frame: .zero)
    }()

    private(set) lazy var weekView: TPCalendarSingleWeekView = {
        return TPCalendarSingleWeekView(frame: bounds)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(top: 5.0)
        addSubview(symbolsView)
        contentView.addSubview(weekView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        symbolsView.width = layoutFrame.width
        symbolsView.height = symbolsViewHeight
        symbolsView.top = layoutFrame.minY
        
        weekView.width = layoutFrame.width
        weekView.height = layoutFrame.height - symbolsViewHeight
        weekView.top = symbolsView.bottom
    }
}
