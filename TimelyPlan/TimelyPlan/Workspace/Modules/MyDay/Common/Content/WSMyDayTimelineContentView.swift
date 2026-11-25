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
/// 只负责头部与时间线的布局；事项数量、更多入口与空白提示均由时间线视图处理。
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(headerView)
        addSubview(timelineView)
        
        /// 点击事项交给交互器打开详情
        timelineView.didSelectEventHandler = { [weak self] event in
            self?.interactor?.performAction(with: WSMyDayTimelineEventItem(event: event))
        }
        
        /// 点击更多入口打开当天的时间线
        timelineView.didSelectMoreHandler = { [weak self] in
            (self?.interactor as? WSMyDayEventsContentInteractor)?.openTimeline()
        }
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
        
        timelineView.frame = CGRect(x: contentFrame.minX,
                                    y: timelineTop,
                                    width: contentFrame.width,
                                    height: max(contentFrame.maxY - timelineTop, 0.0))
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let timelineDataItem = dataItem as? WSMyDayTimelineDataItem
        headerView.date = timelineDataItem?.date
        timelineView.update(with: timelineDataItem?.events ?? [])
        
        setNeedsLayout()
    }
}
