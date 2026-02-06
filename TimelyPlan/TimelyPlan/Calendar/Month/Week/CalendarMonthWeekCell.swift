//
//  CalendarMonthWeekCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/22.
//

import Foundation

class CalendarMonthWeekCell: UICollectionViewCell {
    
    /// 代理对象
    weak var weekViewDelegate: CalendarMonthWeekViewDelegate? {
        get {
            return weekView.delegate
        }
        
        set {
            weekView.delegate = newValue
        }
    }
    
    /// 周开始日的日期
    var weekStartDate: Date?
    
    /// 周视图
    private lazy var weekView: CalendarMonthWeekView = {
        let view = CalendarMonthWeekView(frame: self.bounds)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(weekView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        weekView.frame = bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        weekView.weekStartDate = nil
        weekView.reset()
    }
    
    func reloadData() {
        weekView.weekStartDate = weekStartDate
        weekView.reloadData()
    }
}
