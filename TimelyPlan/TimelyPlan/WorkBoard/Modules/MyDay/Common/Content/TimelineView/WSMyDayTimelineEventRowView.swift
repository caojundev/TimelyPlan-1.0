//
//  WSMyDayTimelineEventRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 事项行视图

/// 插件时间线的事项行：左侧节点（图标或表情）、右侧时间段、名称与详情
class WSMyDayTimelineEventRowView: UIView, TimelineProgressUpdatable {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 节点列宽度，与连接线一致
        static let nodeColumnWidth: CGFloat = TimelineConfig.centerNodeWidth
        
        /// 节点与内容的间距
        static let nodeContentSpacing: CGFloat = 12.0
        
        /// 时间段字体
        static let timeFont = UIFont.systemFont(ofSize: 10.0, weight: .medium)
        
        /// 时间段与名称的间距
        static let timeInfoSpacing: CGFloat = 2.0
        
        /// 名称字体
        static let titleFont = UIFont.boldSystemFont(ofSize: 14.0)
        
        /// 详情字体
        static let subtitleFont = UIFont.systemFont(ofSize: 11.0, weight: .medium)
        
        /// 名称与详情的间距
        static let subtitleTopMargin: CGFloat = 2.0
    }
    
    /// 点击事项回调
    var didSelectHandler: ((MyDayEvent) -> Void)?
    
    /// 节点
    private let nodeView = WSMyDayTimelineNodeView()
    
    /// 当前事项
    private var event: MyDayEvent?
    
    /// 时间段
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.timeFont
        label.textColor = .secondaryLabel
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    /// 名称与详情
    private let infoView: TPInfoView = {
        let view = TPInfoView()
        view.padding = .zero
        view.titleConfig = .withFont(Metrics.titleFont,
                                     numberOfLines: 1,
                                     textColor: .label,
                                     adjustsFontSizeToFitWidth: true,
                                     minimumScaleFactor: 0.8)
        view.subtitleConfig = .withFont(Metrics.subtitleFont,
                                        numberOfLines: 2,
                                        textColor: .secondaryLabel,
                                        adjustsFontSizeToFitWidth: true,
                                        minimumScaleFactor: 0.8)
        view.subtitleLabel.alpha = 0.8
        view.subtitleTopMargin = Metrics.subtitleTopMargin
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        addSubview(nodeView)
        addSubview(timeLabel)
        addSubview(infoView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickRow))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 渲染
    /// 更新展示的事项
    func update(with item: TimelineItem) {
        event = item.event
        nodeView.configure(with: item)
        nodeView.configureIcon(item.event.sourceIcon)
        timeLabel.text = timeText(for: item)
        infoView.title = item.event.displayTitle
        infoView.subtitle = item.event.displaySubtitle
        
        setNeedsLayout()
    }
    
    /// 点击事项
    @objc private func clickRow() {
        guard let event = event else {
            return
        }
        
        didSelectHandler?(event)
    }
    
    /// 时间段文案：开始时间 - 结束时间(持续时长)
    private func timeText(for item: TimelineItem) -> String {
        let range = "\(item.startDate.timeString) - \(item.endDate.timeString)"
        let duration = Int(item.endDate.timeIntervalSince(item.startDate))
        guard let durationString = duration.hourMinuteDurationString else {
            return range
        }
        
        return "\(range)(\(durationString))"
    }
    
    // MARK: - TimelineProgressUpdatable
    func updateTimeProgress() {
        nodeView.updateTimeProgress()
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds.width > 0.0, bounds.height > 0.0 else {
            return
        }
        
        nodeView.frame = CGRect(x: 0.0,
                                y: 0.0,
                                width: Metrics.nodeColumnWidth,
                                height: bounds.height)
        
        layoutContent()
    }
    
    /// 时间段、名称与详情按内容高度居中展示
    private func layoutContent() {
        let contentLeft = Metrics.nodeColumnWidth + Metrics.nodeContentSpacing
        let contentWidth = max(bounds.width - contentLeft, 0.0)
        guard contentWidth > 0.0 else {
            return
        }
        
        let timeHeight = ceil(Metrics.timeFont.lineHeight)
        let titleHeight = TPLabelLayout(content: infoView.titleContent, config: infoView.titleConfig)
            .boundingSize(with: contentWidth).height
        let subtitleHeight = TPLabelLayout(content: infoView.subtitleContent, config: infoView.subtitleConfig)
            .boundingSize(with: contentWidth).height
        
        var infoHeight = titleHeight
        if subtitleHeight > 0.0 {
            infoHeight += infoView.subtitleTopMargin + subtitleHeight
        }
        
        let preferredHeight = timeHeight + Metrics.timeInfoSpacing + infoHeight
        let top = max((bounds.height - preferredHeight) / 2.0, 0.0)
        
        timeLabel.frame = CGRect(x: contentLeft, y: top, width: contentWidth, height: timeHeight)
        
        let infoTop = timeLabel.bottom + Metrics.timeInfoSpacing
        infoView.frame = CGRect(x: contentLeft,
                                y: infoTop,
                                width: contentWidth,
                                height: max(min(infoHeight, bounds.height - infoTop), 0.0))
    }
}
