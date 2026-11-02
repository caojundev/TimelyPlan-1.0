//
//  WSMyDayTimelineContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 内容视图基类

/// 我的一天·时间线的内容视图基类，中、大尺寸共用。
///
/// 顶部为标题与日期，下方为时间线快照；展示条数按可用高度换算，
/// 允许最后一条跨出可见区域，由外层裁剪。
class WSMyDayTimelineContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 头部与时间线的间距
        static let headerListSpacing: CGFloat = 8.0
    }
    
    /// 头部：标题与日期
    private let headerView = WSMyDayHeaderView()
    
    /// 时间线
    private let timelineView = WSMyDayTimelineView()
    
    /// 空白提示：没有正在进行或未结束的事项时展示在头部下方
    private let emptyView: WSPluginDefaultEmptyPlaceholderView = {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.title = resGetString("No Upcoming Events")
        
        let view = WSPluginDefaultEmptyPlaceholderView(configuration: configuration)
        view.isHidden = true
        return view
    }()
    
    /// 当前待展示的事项
    private var events: [MyDayEvent] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(headerView)
        addSubview(timelineView)
        addSubview(emptyView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = layoutFrame()
        guard contentFrame.width > 0.0, contentFrame.height > 0.0 else {
            return
        }
        
        headerView.frame = CGRect(x: contentFrame.minX,
                                  y: contentFrame.minY,
                                  width: contentFrame.width,
                                  height: WSMyDayHeaderView.preferredHeight)
        
        let timelineTop = headerView.bottom + Metrics.headerListSpacing
        let timelineHeight = max(contentFrame.maxY - timelineTop, 0.0)
        
        emptyView.isHidden = !events.isEmpty
        emptyView.frame = CGRect(x: contentFrame.minX,
                                 y: timelineTop,
                                 width: contentFrame.width,
                                 height: timelineHeight)
        
        timelineView.isHidden = events.isEmpty
        timelineView.update(with: events)
        timelineView.maximumItemCount = timelineView.visibleItemCount(forHeight: timelineHeight)
        timelineView.frame = CGRect(x: contentFrame.minX,
                                    y: timelineTop,
                                    width: contentFrame.width,
                                    height: timelineHeight)
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let timelineDataItem = dataItem as? WSMyDayTimelineDataItem
        headerView.date = timelineDataItem?.date
        events = timelineDataItem?.events ?? []
        
        setNeedsLayout()
    }
}
