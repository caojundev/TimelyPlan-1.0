//
//  HabitHomeWeekListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/4.
//

import Foundation
import UIKit

protocol HabitHomeWeekListCellDelegate: AnyObject {
    
    /// 点击更多
    func habitHomeWeekListCell(_ cell: HabitHomeWeekListCell, didClickMore button: UIButton)
    
    /// 点击日期
    func habitHomeWeekListCell(_ cell: HabitHomeWeekListCell, didClickDate date: Date)
}

class HabitHomeWeekListCell: HabitTaskListBaseCell {

    var periodItem: HabitPeriodItem? {
        didSet {
            reloadData()
        }
    }
    
    /// 头视图高度
    private let headerViewHeight = 30.0

    /// 信息视图高度
    let infoViewHeight = 70.0
    
    private lazy var headerView: HabitHomeWeekListCellHeader = {
        let view = HabitHomeWeekListCellHeader()
        view.padding = UIEdgeInsets(left: 8.0, right: 0.0)
        view.moreButton.addTarget(self,
                                  action: #selector(clickMore(_:)),
                                  for: .touchUpInside)
        return view
    }()
    
    private lazy var infoView: HabitTaskDefaultInfoView = {
        let view = HabitTaskDefaultInfoView()
        return view
    }()
    
    /// 周期列表视图
    private let weekViewHeight = 100.0
    private lazy var weekView: HabitDatePeriodsView = {
        let view = HabitDatePeriodsView(frame: bounds)
        view.delegate = self
        return view
    }()
    
    override var focusLineColor: UIColor {
        return periodItem?.habitTask.color.lighterColor ?? .primary
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.padding = UIEdgeInsets(top: 5.0,
                                           left: 8.0,
                                           bottom: 5.0,
                                           right: 8.0)
        contentView.addSubview(headerView)
        contentView.addSubview(infoView)
        contentView.addSubview(weekView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        headerView.width = layoutFrame.width
        headerView.height = headerViewHeight
        headerView.origin = layoutFrame.origin
        
        infoView.width = layoutFrame.width
        infoView.height = infoViewHeight
        infoView.top = headerView.bottom
        infoView.left = layoutFrame.minX
        
        weekView.width = layoutFrame.width
        weekView.height = weekViewHeight
        weekView.top = infoView.bottom
        weekView.left = layoutFrame.minX
    }
    
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        if let delegate = self.delegate as? HabitHomeWeekListCellDelegate {
            delegate.habitHomeWeekListCell(self, didClickMore: button)
        }
    }
    
    override func updateStyleWithColor(_ color: UIColor) {
        super.updateStyleWithColor(color)
        
        let iconView = infoView.iconView
        iconView.foreColor = Color(0xffffff, 0.8)
        iconView.backColor = color
        
        let titleView = infoView.titleView
        titleView.titleConfig.textColor = Color(0xffffff, 0.9)
        titleView.subtitleConfig.textColor = Color(0xffffff, 0.7)
        headerView.titleConfig.textColor = Color(0xffffff, 0.8)
    }
    
    private func updateTaskInfo() {
        let habitTask = periodItem?.habitTask
        updateStyleWithColor(habitTask?.color ?? .primary)
        headerView.title = habitTask?.attributedInfo(color: headerView.titleConfig.textColor)
        infoView.iconView.icon = habitTask?.icon
        infoView.titleView.title = habitTask?.name
        infoView.titleView.subtitle = habitTask?.goal.targetDescription
    }
    
    func reloadData() {
        updateTaskInfo()
        weekView.reloadData()
    }
    
    /// 记录更新
    func updateRecord(on date: Date, with change: HabitRecordChange?, animated: Bool = true) {
        let period = HabitDatePeriod(date: date, mode: .day)
        guard let dayCell = weekView.cellForPeriod(period) as? HabitHomeWeekDayCell else {
            return
        }
        
        dayCell.updateRecord(with: change, animated: animated)
    }
    
    func updateRecords(in period: HabitDatePeriod, animated: Bool) {
        guard let cells = weekView.cells(intersect: period) as? [HabitHomeWeekDayCell] else {
            return
        }
        
        for cell in cells {
            cell.updateRecord(with: nil, animated: true)
        }
    }
}

extension HabitHomeWeekListCell: HabitDatePeriodsViewDelegate {
    
    // MARK: - PeriodsViewDelegate
    func periodsInDatePeriodsView(_ view: HabitDatePeriodsView) -> [HabitDatePeriod]? {
        guard let period = self.periodItem?.period else {
            return nil
        }
        
        return period.weekDaysPeriods()
    }
    
    func datePeriodsView(_ view: HabitDatePeriodsView, cellClassForPeriod period: HabitDatePeriod) -> AnyClass {
        return HabitHomeWeekDayCell.self
    }
    
    func datePeriodsView(_ view: HabitDatePeriodsView, didDequeCell cell: UICollectionViewCell, forPeriod period: HabitDatePeriod) {
        let cell = cell as! HabitHomeWeekDayCell
        let date = period.date
        cell.date = date
        cell.periodItem = self.periodItem
        cell.isScheduledDay = self.periodItem?.isScheduledDate(date) ?? true
        cell.reloadData() /// 加载内容数据
    }
    
    func datePeriodsView(_ view: HabitDatePeriodsView, didSelectPeriod period: HabitDatePeriod) {
        TPImpactFeedback.impactWithSoftStyle()
        if let delegate = self.delegate as? HabitHomeWeekListCellDelegate {
            delegate.habitHomeWeekListCell(self, didClickDate: period.date)
        }
    }
    
    func datePeriodsView(_ view: HabitDatePeriodsView, shouldHighlightPeriod period: HabitDatePeriod) -> Bool {
        return !period.isFuture /// 未来时段禁止高亮
    }
}
