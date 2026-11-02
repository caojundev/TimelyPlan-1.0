//
//  WSMyDaySmallUpcomingContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 我的一天·小·临近事项的内容视图。
///
/// 自上而下依次为事项节点、时间段、事项信息与重叠事项数目；
/// 展示哪一条事项由当前时间解析，每分钟刷新一次。
class WSMyDaySmallUpcomingContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 10.0)
        
        /// 头部与节点的间距
        static let headerNodeSpacing: CGFloat = 6.0
        
        /// 节点与时间段的间距
        static let nodeTimeSpacing: CGFloat = 4.0
        
        /// 时间段与信息视图的间距
        static let timeInfoSpacing: CGFloat = 4.0
        
        /// 信息视图与重叠数目的间距
        static let infoOverlapSpacing: CGFloat = 4.0
        
        /// 时间段字体
        static let timeFont = UIFont.boldSystemFont(ofSize: 12.0)
        
        /// 标题字体
        static let titleFont = UIFont.boldSystemFont(ofSize: 15.0)
        
        /// 副标题字体
        static let subtitleFont = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        
        /// 标题与副标题的间距
        static let subtitleTopMargin: CGFloat = 2.0
        
        /// 重叠数目字体
        static let overlapFont = UIFont.boldSystemFont(ofSize: 11.0)
    }
    
    /// 头部：标题与日期
    private let headerView = WSMyDayHeaderView()
    
    /// 空白提示：没有临近事项时展示在头部下方
    private let emptyView: WSPluginDefaultEmptyPlaceholderView = {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.title = resGetString("No Upcoming Events")
        
        let view = WSPluginDefaultEmptyPlaceholderView(configuration: configuration)
        view.isHidden = true
        return view
    }()
    
    /// 事项节点
    private let nodeView = WSMyDayUpcomingNodeView()
    
    /// 时间段
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.timeFont
        label.textColor = .secondaryLabel
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    /// 事项信息
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
    
    /// 重叠事项入口
    private lazy var overlapButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = .zero
        button.titleConfig.font = Metrics.overlapFont
        button.titleConfig.textColor = .primary
        button.titleConfig.textAlignment = .left
        button.titleConfig.adjustsFontSizeToFitWidth = true
        button.titleConfig.minimumScaleFactor = 0.7
        button.hitTestEdgeInsets = UIEdgeInsets(value: -6.0)
        button.isHidden = true
        button.didClickHandler = { [weak self] in
            (self?.interactor as? WSMyDayUpcomingContentInteractor)?.clickOverlapping()
        }
        return button
    }()
    
    /// 分钟刷新，用于更新节点进度与切换展示事项
    private let minuteUpdater = TPMinuteUpdater()
    
    /// 今天的非全天事项
    private var items: [WSMyDayUpcomingEventItem] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = Metrics.padding
        
        addSubview(headerView)
        addSubview(emptyView)
        addSubview(nodeView)
        addSubview(timeLabel)
        addSubview(infoView)
        addSubview(overlapButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        minuteUpdater.stop()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if window == nil {
            minuteUpdater.stop()
        } else {
            startUpdating()
        }
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
        
        emptyView.frame = CGRect(x: contentFrame.minX,
                                 y: headerView.bottom + Metrics.headerNodeSpacing,
                                 width: contentFrame.width,
                                 height: max(contentFrame.maxY - headerView.bottom - Metrics.headerNodeSpacing, 0.0))
        
        nodeView.size = WSMyDayUpcomingNodeView.preferredSize
        nodeView.left = contentFrame.minX
        nodeView.top = headerView.bottom + Metrics.headerNodeSpacing
        
        /// 时间段与信息视图整体靠底布局，空白留在节点下方
        let overlapHeight = ceil(Metrics.overlapFont.lineHeight)
        let timeHeight = ceil(Metrics.timeFont.lineHeight)
        let infoHeight = infoContentHeight(width: contentFrame.width)
        let overlapBlock = overlapButton.isHidden ? 0.0 : overlapHeight + Metrics.infoOverlapSpacing
        let blockHeight = timeHeight + Metrics.timeInfoSpacing + infoHeight + overlapBlock
        let blockTop = max(nodeView.bottom + Metrics.nodeTimeSpacing,
                           contentFrame.maxY - blockHeight)
        
        timeLabel.size = CGSize(width: contentFrame.width, height: timeHeight)
        timeLabel.left = contentFrame.minX
        timeLabel.top = blockTop
        
        let infoTop = timeLabel.bottom + Metrics.timeInfoSpacing
        let infoMaxHeight = max(contentFrame.maxY - overlapBlock - infoTop, 0.0)
        infoView.frame = CGRect(x: contentFrame.minX,
                                y: infoTop,
                                width: contentFrame.width,
                                height: min(infoHeight, infoMaxHeight))
        
        overlapButton.size = CGSize(width: contentFrame.width, height: overlapHeight)
        overlapButton.left = contentFrame.minX
        overlapButton.bottom = contentFrame.maxY
    }
    
    /// 信息视图所需的高度：标题一行 + 副标题实际行数
    private func infoContentHeight(width: CGFloat) -> CGFloat {
        let titleHeight = TPLabelLayout(content: infoView.titleContent, config: infoView.titleConfig)
            .boundingSize(with: width).height
        let subtitleHeight = TPLabelLayout(content: infoView.subtitleContent, config: infoView.subtitleConfig)
            .boundingSize(with: width).height
        
        guard subtitleHeight > 0.0 else {
            return titleHeight
        }
        
        return titleHeight + infoView.subtitleTopMargin + subtitleHeight
    }
    
    // MARK: - 时间刷新
    private func startUpdating() {
        minuteUpdater.start { [weak self] in
            self?.reloadDisplay()
        }
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let upcomingDataItem = dataItem as? WSMyDayUpcomingDataItem
        headerView.date = upcomingDataItem?.date
        items = upcomingDataItem?.items ?? []
        reloadDisplay()
    }
    
    /// 按当前时间刷新展示内容
    private func reloadDisplay() {
        guard let display = WSMyDayUpcomingResolver.resolve(items: items, at: Date()) else {
            /// 没有进行中或后续事项时，头部下方展示空白提示
            emptyView.isHidden = false
            nodeView.isHidden = true
            timeLabel.isHidden = true
            infoView.isHidden = true
            timeLabel.text = nil
            infoView.title = nil
            infoView.subtitle = nil
            overlapButton.isHidden = true
            setNeedsLayout()
            return
        }
        
        let item = display.item
        emptyView.isHidden = true
        nodeView.isHidden = false
        timeLabel.isHidden = false
        infoView.isHidden = false
        nodeView.update(color: item.color, progress: display.progress, icon: item.sourceIcon)
        
        timeLabel.text = "\(item.startDate.timeString) - \(item.endDate.timeString)"
        infoView.title = item.title
        infoView.subtitle = item.subtitle
        
        /// 没有重叠事项时不展示数目
        overlapButton.isHidden = display.overlappingCount <= 0
        if display.overlappingCount > 0 {
            overlapButton.title = String(format: resGetString("Overlapping %ld"), display.overlappingCount)
        }
        
        setNeedsLayout()
    }
}
