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
}

class HabitHomeWeekListCell: HabitTaskListBaseCell {

    var task: HabitPeriodTask? {
        didSet {
            updateTaskInfo()
        }
    }
    
    /// 头视图高度
    let headerViewHeight = 30.0
    
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
    let weekViewHeight = 100.0
    lazy var weekView: HabitDatePeriodsView = {
        let view = HabitDatePeriodsView(frame: bounds)
        view.delegate = self
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.padding = UIEdgeInsets(top: 5.0,
                                           left: 8.0,
                                           bottom: 5.0,
                                           right: 8.0)
        contentView.addSubview(headerView)
        contentView.addSubview(infoView)
        contentView.addSubview(weekView)
        weekView.reloadData()
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
    
    func updateTaskInfo() {
        let habitTask = task?.habitTask
        updateStyleWithColor(habitTask?.color ?? .primary)
        headerView.title = habitTask?.attributedInfo
        infoView.iconView.icon = habitTask?.icon
        infoView.titleView.title = habitTask?.name
        infoView.titleView.subtitle = habitTask?.goal.targetDescription
    }
    
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        if let delegate = self.delegate as? HabitHomeWeekListCellDelegate {
            delegate.habitHomeWeekListCell(self, didClickMore: button)
        }
    }
}

extension HabitHomeWeekListCell: HabitDatePeriodsViewDelegate {
    
    // MARK: - PeriodsViewDelegate
    func periodsInDatePeriodsView(_ view: HabitDatePeriodsView) -> [HabitDatePeriod]? {
        let firstWeekday = HabitSetting.shared.firstWeekday
        return HabitDatePeriod.weekDaysPeriods(containing: .now, firstWeekday: firstWeekday)
    }
    
    func datePeriodsView(_ view: HabitDatePeriodsView, cellClassForPeriod period: HabitDatePeriod) -> AnyClass {
        return HabitHomeWeekDayCell.self
    }
    
    func datePeriodsView(_ view: HabitDatePeriodsView, didDequeCell cell: UICollectionViewCell, forPeriod period: HabitDatePeriod) {
        let cell = cell as! HabitHomeWeekDayCell
        cell.date = period.date
        cell.reloadData() /// 加载内容数据
    }
    
    func datePeriodsView(_ view: HabitDatePeriodsView, didSelectPeriod period: HabitDatePeriod) {
        
    }
    
    func datePeriodsView(_ view: HabitDatePeriodsView, shouldHighlightPeriod period: HabitDatePeriod) -> Bool {
        return !period.isFuture /// 未来时段禁止高亮
    }
}
