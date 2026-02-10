//
//  CalendarDatePageView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/8.
//

import Foundation

protocol CalendarDatePageViewDelegate: AnyObject {

    /// 日历视图切换到新日期
    func calendarDayPagingView(_ pageView: CalendarDatePageView,
                               didChangeVisibleDateFromDate fromDate: Date,
                               toDate: Date)
    
    /// 结束手指拖动
    func calendarDayPagingViewWillEndDragging(_ pageView: CalendarDatePageView,
                                              withTargetDate targetDate: Date)
}

extension CalendarDatePageViewDelegate {
    
    func calendarDayPagingView(_ pageView: CalendarDatePageView,
                               didChangeVisibleDateFromDate fromDate: Date,
                               toDate: Date) {}
    
    func calendarDayPagingViewWillEndDragging(_ pageView: CalendarDatePageView,
                                              withTargetDate targetDate: Date) {}
}

class CalendarDatePageView: TPCollectionWrapperView,
                             TPCollectionViewAdapterDataSource,
                            TPCollectionViewAdapterDelegate {
    
    /// 代理对象
    weak var delegate: CalendarDatePageViewDelegate?
    
    private(set) var visibleDate: Date!
    
    /// 当前月左右条数目
    let kNearItemsCount = 3

    init(frame: CGRect, visibleDate: Date = .now) {
        super.init(frame: frame)
        self.visibleDate = validatedDate(visibleDate)
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
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
        adapter.performUpdate()
        CATransaction.commit()
        updateContentOffset(animated: false)
        
        /// 日期变化回调
        delegate?.calendarDayPagingView(self,
                                        didChangeVisibleDateFromDate: fromDate,
                                        toDate: toDate)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offset = targetContentOffset.pointee
        let targetDate = date(at: offset)
        delegate?.calendarDayPagingViewWillEndDragging(self, withTargetDate: targetDate)
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
        if visibleDate == date {
            return
        }
        
        let animateStyle = SlideStyle.horizontalStyle(fromValue: visibleDate,
                                                        toValue: date)
        visibleDate = date
        reloadData(animateStyle: animateStyle)
    }
    
    // MARK: - 子类重写
    func getDates() -> [Date]? {
        return nil
    }
    
    func validatedDate(_ date: Date) -> Date {
        return date
    }
    
    // MARK: - Private Metehods
    /// 更新内容偏移
    private func updateContentOffset(animated: Bool) {
        var index = kNearItemsCount
        if let indexPath = adapter.indexPath(of: visibleDate as NSDate) {
            index = indexPath.item
        }
        
        var offset = CGPoint.zero
        offset.x = bounds.width * CGFloat(index)
        collectionView.contentOffset = offset
    }
    
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
