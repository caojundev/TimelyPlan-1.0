//
//  FocusTimelineDayPageView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/7.
//

import Foundation

class FocusTimelineDayPageView: FocusDatePageView {
    
    /// 点击事件代理
    weak var tapDelegate: FocusTimelineEventListTapDelegate?
    
    /// 小时高度
    var hourHeight: CGFloat = 80.0 {
        didSet {
            updateHourHeight()
        }
    }
    
    private let timelineTopPadding = 20.0
    
    private let timelineBottomPadding = 40.0
    
    /// 时间线打开时自动定位到的小时
    lazy var autoScrollHour: Int = {
        return Date().hour
    }()
    
    /// 滚动同步器
    private var synchronizer: FocusTimelineSynchronizer?
    
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return FocusTimelineDayTimelineCell.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        /// 需要立即布局以解决滚动跳动的问题
        cell.layoutIfNeeded()
        
        guard let cell = cell as? FocusTimelineDayTimelineCell else {
            return
        }
        
        let date = adapter.item(at: indexPath) as! Date
        cell.date = date
        let timelineView = cell.timelineView
        timelineView.hourHeight = hourHeight
        timelineView.topPadding = timelineTopPadding
        timelineView.bottomPadding = timelineBottomPadding
        timelineView.tapDelegate = tapDelegate  // 设置点击代理
        timelineView.layoutIfNeeded()
        timelineView.loadEvents(for: date)

        /// 将时间线视图添加到同步器
        let synchronizer = getSynchronizer()
        synchronizer.addTimelineView(timelineView)
    }
    
    private func getSynchronizer() -> FocusTimelineSynchronizer {
        if let synchronizer = synchronizer {
            return synchronizer
        }
        
        let synchronizer = FocusTimelineSynchronizer()
        let maxY = hourHeight * CGFloat(HOURS_PER_DAY)
        let offsetY = CGFloat(autoScrollHour) * hourHeight
        synchronizer.setContentOffset(CGPoint(x: 0.0, y: min(offsetY, maxY)))
        self.synchronizer = synchronizer
        return synchronizer
    }
    
    /// 更新时间线视图小时高度
    private func updateHourHeight() {
        guard let cells = collectionView.visibleCells as? [FocusTimelineDayTimelineCell] else {
            return
        }
        
        for cell in cells {
            cell.timelineView.hourHeight = hourHeight
        }
    }
}

class FocusTimelineDayTimelineCell: FocusDatePageCell {

    let timelineView = FocusTimelineView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(timelineView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timelineView.frame = bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timelineView.reset()
    }
}
