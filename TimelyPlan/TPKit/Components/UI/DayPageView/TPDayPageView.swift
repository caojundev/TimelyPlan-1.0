//
//  DayPageView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/19.
//

import Foundation
import UIKit

protocol TPDayPageViewDelegate: AnyObject {

    /// 天页面视图切换到新日期
    func dayPageView(_ pageView: TPDayPageView,
                     didChangeVisibleDateFromDate fromDate: Date,
                     toDate: Date)
    
    /// 结束手指拖动
    func dayPageViewWillEndDragging(_ pageView: TPDayPageView,
                                    withTargetDate targetDate: Date)
}

extension TPDayPageViewDelegate {
    func dayPageView(_ pageView: TPDayPageView,
                     didChangeVisibleDateFromDate fromDate: Date,
                     toDate: Date) {}
    
    func dayPageViewWillEndDragging(_ pageView: TPDayPageView,
                                    withTargetDate targetDate: Date) {}
}

class TPDayPageView: TPCollectionWrapperView,
                     TPCollectionViewAdapterDataSource,
                     TPCollectionViewAdapterDelegate {
    
    /// 代理对象
    weak var delegate: TPDayPageViewDelegate?
    
    /// 当前月左右条数目
    private let kNearItemsCount = 8

    private(set) var visibleDate: Date!
    
    init(frame: CGRect, visibleDate: Date = .now) {
        self.visibleDate = visibleDate.startOfDay()
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        scrollDirection = .horizontal
        adapter.cellStyle.backgroundColor = .clear
        adapter.cellStyle.selectedBackgroundColor = .clear
        adapter.dataSource = self
        adapter.delegate = self
        reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        /// 更新内容偏移
        updateContentOffset(animated: false)
        
        /// 内容偏移可能会被 collectionView 布局覆盖，在下一个 Runloop 再更新一次
        DispatchQueue.main.async {
            self.updateContentOffset(animated: false)
        }
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.isPagingEnabled = true
        collectionView.decelerationRate = .fast
    }
    
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return [String(describing: type(of: self)) as NSString]
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        guard let dates = getDates() else {
            return nil
        }
        
        return dates as [NSDate]
    }

    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return UICollectionViewCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? TPDayPageCell,
                let date = adapter.item(at: indexPath) as? Date else {
            return
        }
        
        cell.date = date
    }

    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return adapter.collectionViewSize()
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let toDate = date(at: scrollView.contentOffset)
        if visibleDate == toDate {
            return
        }

        let fromDate = visibleDate!
        visibleDate = toDate

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        adapter.performUpdate(updateVisibleItems: false)
        CATransaction.commit()
        updateContentOffset(animated: false)
        
        /// 日期变化回调
        delegate?.dayPageView(self, didChangeVisibleDateFromDate: fromDate, toDate: toDate)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offset = targetContentOffset.pointee
        let targetDate = date(at: offset)
        delegate?.dayPageViewWillEndDragging(self, withTargetDate: targetDate)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    // MARK: - Public Methods
    override func reloadData() {
        super.reloadData()
        updateContentOffset(animated: false)
    }
    
    override func reloadData(animateStyle: SlideStyle) {
        super.reloadData(animateStyle: animateStyle)
        updateContentOffset(animated: false)
    }
    
    /// 当前月份日期组件
    func setVisibleDate(_ date: Date, animated: Bool) {
        let date = validatedDate(date)
        guard !visibleDate.isInSameDayAs(date) else {
            return
        }
        
        let animateStyle = SlideStyle.horizontalStyle(fromValue: visibleDate, toValue: date)
        visibleDate = date
        reloadData(animateStyle: animateStyle)
    }
    
    /// 判断日期是否可见
    func isVisibleDate(_ date: Date) -> Bool {
        if visibleDate.isInSameDayAs(date) {
            return true
        }

        if collectionView.isDragging {
            let dates = adapter.allItems() as! [Date]
            /// 当 contentOffset 当前位置非整页时，计算当前显示的是哪两页
            let currentPageIndex = validatedIndex(Int(collectionView.contentOffset.x / bounds.width))
            if dates[currentPageIndex].isInSameDayAs(date) {
                return true
            }

            // 非显示完整页面，检查下一页
            let nextPageIndex = validatedIndex(currentPageIndex + 1)
            if dates[nextPageIndex].isInSameDayAs(date) {
                return true
            }
        }
        
        if let visibleCells = collectionView.visibleCells as? [TPDayPageCell] {
            for visibleCell in visibleCells {
                if visibleCell.date.isInSameDayAs(date) {
                    return true
                }
            }
        }
        
        return false
    }
    
    // MARK: - 子类重写
    func getDates() -> [Date]? {
        var dates: [Date] = [visibleDate]
        for i in 1...5 {
            let leftDate = visibleDate.dateByAddingDays(-i)!
            dates.insert(leftDate, at: 0)
            let rightDate = visibleDate.dateByAddingDays(i)!
            dates.append(rightDate)
        }

        return dates
    }
    
    func validatedDate(_ date: Date) -> Date {
        return date.startOfDay()
    }
    
    /// 更新内容偏移
    func updateContentOffset(animated: Bool) {
        var index = kNearItemsCount
        if let indexPath = adapter.indexPath(of: visibleDate as NSDate) {
            index = indexPath.item
        }
        
        var offset = CGPoint.zero
        offset.x = bounds.width * CGFloat(index)
        collectionView.contentOffset = offset
    }
    
    // MARK: - Private Metehods
    func validatedIndex(_ index: Int) -> Int {
        return min(2 * kNearItemsCount, max(0, index))
    }
    
    private func date(at contentOffset: CGPoint) -> Date {
        let width = collectionView.frame.size.width
        var index = Int(contentOffset.x / width)
        index = validatedIndex(index)
        let indexPath = IndexPath(item: index, section: 0)
        let date = adapter.item(at: indexPath) as! Date
        return date
    }
    
    /// 判断当前是否显示完整页面
    /// - Returns: true表示显示完整页面，false表示显示部分页面
    func isShowingFullPage() -> Bool {
        let contentOffsetX = collectionView.contentOffset.x
        let pageWidth = bounds.width
        
        // 避免除零错误
        guard pageWidth > 0 else { return false }
        
        // 计算当前偏移量相对于页面宽度的余数
        let remainder = contentOffsetX.truncatingRemainder(dividingBy: pageWidth)
        
        // 设置一个很小的容差值，避免浮点数精度问题
        let tolerance: CGFloat = 0.0
        
        // 如果余数接近0或接近pageWidth，则认为是完整页面
        return remainder < tolerance || remainder > (pageWidth - tolerance)
    }
}

class TPDayPageCell: TPCollectionCell {
    
    var date: Date = .now
    
}
