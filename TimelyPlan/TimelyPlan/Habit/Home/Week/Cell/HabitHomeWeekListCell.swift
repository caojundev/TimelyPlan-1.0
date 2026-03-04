//
//  HabitHomeWeekListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/4.
//

import Foundation
import UIKit

class HabitHomeWeekListCell: HabitTaskBaseListCell {

    /// 头视图高度
    let headerViewHeight = 30.0
    
    /// 信息视图高度
    let infoViewHeight = 70.0
    
    private lazy var headerView: HabitHomeWeekListCellHeader = {
        let view = HabitHomeWeekListCellHeader()
        return view
    }()
    
    private lazy var infoView: HabitTaskDefaultInfoView = {
        let view = HabitTaskDefaultInfoView()
        return view
    }()
    
    /// 周期列表视图
    let weekViewHeight = 100.0
    lazy var weekView: DatePeriodsView = {
        let view = DatePeriodsView(frame: bounds)
        view.delegate = self
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.padding = UIEdgeInsets(top: 5.0,
                                           left: 16.0,
                                           bottom: 5.0,
                                           right: 8.0)
        contentView.addSubview(headerView)
        contentView.addSubview(infoView)
        contentView.addSubview(weekView)
        weekView.reloadData()
        
        
        
        updateStyleWithColor(UIColor.randomHabitTaskColor)
        headerView.title = "进行中 每周于周一、周三和周五"
        infoView.iconView.icon = TPIcon(text: Character.randomEmojiString())
        infoView.titleView.title = "阅读文档"
        infoView.titleView.subtitle = "每天阅读100页"
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
        
//        headerView.backgroundColor = .random
//        infoView.backgroundColor = .random
//        weekView.backgroundColor = .random
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
}

extension HabitHomeWeekListCell: DatePeriodsViewDelegate {
    
    // MARK: - PeriodsViewDelegate
    func periodsInDatePeriodsView(_ view: DatePeriodsView) -> [DatePeriod]? {
        let firstWeekday = HabitSetting.shared.firstWeekday
        return DatePeriodsProvider.weekPeriods(firstWeekday: firstWeekday)
    }
    
    func datePeriodsView(_ view: DatePeriodsView, cellClassForPeriod period: DatePeriod) -> AnyClass {
        return HabitHomeWeekDayCell.self
    }
    
    func datePeriodsView(_ view: DatePeriodsView, didDequeCell cell: UICollectionViewCell, forPeriod period: DatePeriod) {
        let cell = cell as! HabitHomeWeekDayCell
        cell.date = period.date
        cell.reloadData() /// 加载内容数据
    }
    
    func datePeriodsView(_ view: DatePeriodsView, didSelectPeriod period: DatePeriod) {
        
    }
    
    func datePeriodsView(_ view: DatePeriodsView, shouldHighlightPeriod period: DatePeriod) -> Bool {
        return !period.isFuture /// 未来时段禁止高亮
    }
}
