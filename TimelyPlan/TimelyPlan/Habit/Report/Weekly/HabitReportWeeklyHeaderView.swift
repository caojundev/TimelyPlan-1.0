//
//  HabitReportWeeklyHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/17.
//

import Foundation
import UIKit

class HabitReportWeeklyHeaderView: HabitReportRoundCornerHeaderFooterView {
    
    var firstWeekday: Weekday = .firstWeekday
    
    /// 周符号视图
    private let symbolsViewHeight = 20.0
    
    private(set) lazy var symbolsView: TPWeekdaySymbolView = {
        return TPWeekdaySymbolView(frame: .zero)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.symbolsView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let weekMargins = HabitReportWeeklyCell.weekMargins
        let contentLayoutFrame = contentView.layoutFrame()
        let layoutFrame = contentLayoutFrame.inset(by: weekMargins)
        
        symbolsView.height = symbolsViewHeight
        symbolsView.width = layoutFrame.width
        symbolsView.right = layoutFrame.maxX
        symbolsView.bottom = contentView.height
    }
    
    func reloadData() {
        symbolsView.firstWeekday = firstWeekday
        symbolsView.reloadData()
    }
}
