//
//  HabitReportYearChartView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/18.
//

import Foundation
import UIKit

protocol HabitReportYearChartViewScrollDelegate: AnyObject {
    
    func habitReportYearChartViewDidScroll(_ chartView: HabitReportYearChartView)
}

class HabitReportYearChartView: TPCollectionWrapperView,
                                TPCollectionViewAdapterDataSource,
                                TPCollectionViewAdapterDelegate,
                                TFSectionTitleFlowLayoutTitleProvider {
    
    var scrollDelegate: HabitReportYearChartViewScrollDelegate?
    
    /// 任务
    var periodTask: HabitPeriodTask?

    /// 区块内间距
    let sectionInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 10.0, right: 0.0)

    var imageCacher: HabitReportImageCacher?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.hideScrollIndicator()
        let flowLayout = TPSectionTitleFlowLayout()
        flowLayout.titleConfig.font = .boldSystemFont(ofSize: 12.0)
        flowLayout.scrollDirection = .horizontal
        flowLayout.titleHeight = sectionInset.top
        flowLayout.titleProvider = self
        setCollectionViewLayout(flowLayout)
        
        adapter.cellStyle.cornerRadius = 4.0
        adapter.cellStyle.backgroundColor = .clear
        adapter.cellStyle.selectedBackgroundColor = .clear
        adapter.sectionInset = sectionInset
        adapter.lineSpacing = 0.0
        adapter.interitemSpacing = 0.0
        adapter.dataSource = self
        adapter.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - TFSectionTitleFlowLayoutTitleProvider
    func sectionTitleFlowLayout(_ layout: TPSectionTitleFlowLayout, titleForSection section: Int) -> String? {
        let month = section + 1
        return Date.monthSymbol(ofMonth: month)
    }
    
    // MARK: - CollectionListDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        let date = periodTask?.period.date ?? .now
        return Date.monthDatesOfYear(contain: date) as [NSDate]
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return [sectionObject]
    }
    
    // MARK: - CollectionListDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return HabitReportYearlyMonthCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? HabitReportYearlyMonthCell else {
            return
        }
        
        cell.imageCacher = self.imageCacher
        cell.date = adapter.item(at: indexPath) as? Date
        cell.periodTask = self.periodTask
        cell.reloadData()
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let periodTask = periodTask, let date = adapter.item(at: indexPath) as? Date else {
            return .zero
        }
        
        let cellHeight = adapter.collectionViewSize().height - sectionInset.verticalLength
        let itemMargin = 5.0
        let lineSpacing = 5.0
        let itemWidth = (cellHeight - CGFloat(DAYS_PER_WEEK + 1) * itemMargin) / CGFloat(DAYS_PER_WEEK)
        let weeksCount = date.numberOfWeeksInMonth(firstWeekday: periodTask.period.firstWeekday)
        let cellWidth = CGFloat(weeksCount) * (itemWidth + lineSpacing) + lineSpacing
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    var contentOffset: CGPoint {
        get {
            return collectionView.contentOffset
        }
        
        set {
            collectionView.contentOffset = newValue
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.habitReportYearChartViewDidScroll(self)
    }
}

class HabitReportYearChartSynchronizer: NSObject, HabitReportYearChartViewScrollDelegate {

    private var contentOffset: CGPoint = .zero
    
    internal var chartViews = NSHashTable<HabitReportYearChartView>.weakObjects()
    
    private func synchronize() {
        for chartView in chartViews.allObjects {
            chartView.contentOffset = contentOffset
        }
    }
    
    func setContentOffset(_ contentOffset: CGPoint) {
        self.contentOffset = contentOffset
        synchronize()
    }
    
    // MARK: - 添加和移除更新器
    func addChartView(_ chartView: HabitReportYearChartView) {
        if !chartViews.contains(chartView) {
            chartView.contentOffset = contentOffset
            chartViews.add(chartView)
            chartView.scrollDelegate = self
        }
    }

    // MARK: - HabitReportYearChartViewScrollDelegate
    func habitReportYearChartViewDidScroll(_ chartView: HabitReportYearChartView) {
        self.contentOffset = chartView.contentOffset
        self.synchronize()
    }
}

