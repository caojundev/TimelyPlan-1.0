//
//  HabitStatsCalendarWeekCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/15.
//

import Foundation
import UIKit

class HabitStatsCalendarWeekCellItem: TPCollectionCellItem {

    weak var weekViewDelegate: HabitDatePeriodsViewDelegate?
    
    override init() {
        super.init()
        self.registerClass = HabitStatsCalendarWeekCell.self
        self.contentPadding = UIEdgeInsets(horizontal: 5.0, vertical: 10.0)
        self.canHighlight = false
        self.size = CGSize(width: .greatestFiniteMagnitude, height: 120.0)
    }
}

class HabitStatsCalendarWeekCell: TPCollectionCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            reloadData()
        }
    }
    
    /// 周期列表视图
    private let weekViewHeight = 100.0
    private lazy var weekView: HabitDatePeriodsView = {
        let view = HabitDatePeriodsView(frame: bounds)
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(weekView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        
        weekView.width = layoutFrame.width
        weekView.height = weekViewHeight
        weekView.origin = layoutFrame.origin
    }
    
    func reloadData() {
        let cellItem = cellItem as! HabitStatsCalendarWeekCellItem
        weekView.delegate = cellItem.weekViewDelegate
        weekView.reloadData()
        setNeedsLayout()
    }
}
