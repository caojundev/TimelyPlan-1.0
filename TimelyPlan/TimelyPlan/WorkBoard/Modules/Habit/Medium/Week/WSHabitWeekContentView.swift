//
//  WSHabitWeekContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 习惯·中·周进度的内容视图。
///
/// 上方为任务图标与名称，下方用天容器展示本周每天的状态与进度；
/// 没有顶部头视图，配色使用普通行颜色。
class WSHabitWeekContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 8.0, right: 16.0)
        
        /// 图标与信息视图高度
        static let infoHeight: CGFloat = 50.0
        
        /// 天视图高度：星期、进度圆环与今日指示圆点的总高
        static let daysHeight: CGFloat = 86.0
        
        /// 标题字号
        static let titleFont = UIFont.boldSystemFont(ofSize: 14.0)
        
        /// 副标题字号
        static let subtitleFont = UIFont.systemFont(ofSize: 12.0, weight: .medium)
    }
    
    /// 任务图标与名称
    private let infoView: HabitTaskDefaultInfoView = {
        let view = HabitTaskDefaultInfoView()
        view.iconSize = CGSize(value: Metrics.infoHeight)
        view.iconView.size = CGSize(value: Metrics.infoHeight)
        view.iconView.cornerRadius = Metrics.infoHeight / 2.0
        return view
    }()
    
    /// 每天的状态与进度
    private let dayContainerView = WSHabitDayContainerView()
    
    /// 当前展示的周数据
    private var weekDataItem: WSHabitPeriodDataItem? {
        return dataItem as? WSHabitPeriodDataItem
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        
        let titleView = infoView.titleView
        titleView.padding = UIEdgeInsets(left: 10.0)
        titleView.subtitleTopMargin = 2.0
        titleView.titleConfig = .withFont(Metrics.titleFont,
                                          textColor: .label,
                                          adjustsFontSizeToFitWidth: true,
                                          minimumScaleFactor: 0.7)
        
        let subtitleConfig = TPLabelConfig.withFont(Metrics.subtitleFont,
                                                    textColor: .secondaryLabel,
                                                    adjustsFontSizeToFitWidth: true,
                                                    minimumScaleFactor: 0.7)
        titleView.subtitleConfig = subtitleConfig
        
        dayContainerView.didSelectDayHandler = { [weak self] dayItem in
            guard let self = self else {
                return
            }
            
            (self.interactor as? WSHabitWeekContentInteractor)?.showDayMenu(for: dayItem)
        }
        
        infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickInfo)))
        
        addSubview(infoView)
        addSubview(dayContainerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        guard layoutFrame.width > 0.0, layoutFrame.height > 0.0 else {
            return
        }
        
        infoView.frame = CGRect(x: layoutFrame.minX,
                                y: layoutFrame.minY,
                                width: layoutFrame.width,
                                height: Metrics.infoHeight)
        
        dayContainerView.width = layoutFrame.width
        dayContainerView.height = Metrics.daysHeight
        dayContainerView.left = layoutFrame.minX
        dayContainerView.bottom = layoutFrame.maxY
    }
    
    // MARK: - 交互
    /// 点击任务信息：打开统计页
    @objc private func clickInfo() {
        guard let weekDataItem = weekDataItem else {
            return
        }
        
        interactor?.performAction(with: weekDataItem)
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem as? WSHabitPeriodDataItem else {
            infoView.isHidden = true
            dayContainerView.isHidden = true
            dayContainerView.dayItems = []
            infoView.iconView.icon = nil
            infoView.iconView.backColor = .clear
            infoView.titleView.title = nil
            infoView.titleView.subtitle = nil
            setNeedsLayout()
            return
        }
        
        infoView.isHidden = false
        dayContainerView.isHidden = false
        
        infoView.iconView.icon = dataItem.icon
        infoView.iconView.foreColor = Color(0xFFFFFF, 0.8)
        infoView.iconView.backColor = dataItem.color
        infoView.titleView.title = dataItem.title
        infoView.titleView.subtitle = dataItem.subtitle
        
        dayContainerView.dayItems = dataItem.days
        setNeedsLayout()
    }
}
