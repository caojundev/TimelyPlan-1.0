//
//  TPCalendarScrollableMonthView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/11.
//

import Foundation

class TPCalendarScrollableMonthView: TPCollectionWrapperView,
                                         TPCollectionViewAdapterDataSource,
                                         TPCollectionViewAdapterDelegate {
    
    /// 月份视图代理对象
    weak var delegate: TPCalendarMonthViewDelegate?
    
    /// 日历视图切换到新月份回调
    var didChangeVisibleDateComponents: ((_ currentDateComponents: DateComponents,
                                          _ previousDateComponents: DateComponents) -> Void)?
    
    /// 当前月份日期组件
    var visibleDateComponents: DateComponents = Date().yearMonthComponents

    /// 日期选择管理器
    var selection: TPCalendarDateSelection? = TPCalendarSingleDateSelection()
    
    /// 当前月左右月份数目
    private let kNearMonthsCount = 5

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
        updateContentOffset(animated: false)
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
        var dateComponentsArray = [visibleDateComponents]
        for i in 1...kNearMonthsCount {
            let leftDateComponents = visibleDateComponents.yearMonthCompontentsByAddingMonths(-i)!
            dateComponentsArray.insert(leftDateComponents, at: 0)
            let rightDateComponents = visibleDateComponents.yearMonthCompontentsByAddingMonths(i)!
            dateComponentsArray.append(rightDateComponents)
        }

        return dateComponentsArray as [NSDateComponents]
    }

    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return TPCalendarSingleMonthCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? TPCalendarSingleMonthCell, let monthView = cell.monthView else {
            return
        }
        
        let dateComponents = adapter.item(at: indexPath) as! DateComponents
        monthView.delegate = delegate
        monthView.visibleDateComponents = dateComponents
        monthView.selection = selection
        monthView.reloadData()
    }

    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return adapter.collectionViewSize()
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.size.width
        var index = Int(scrollView.contentOffset.x / width)
        index = min(2 * kNearMonthsCount, max(0, index))
        let indexPath = IndexPath(item: index, section: 0)

        let toDateComponents = adapter.item(at: indexPath) as! DateComponents
        if visibleDateComponents == toDateComponents {
            return
        }

        let fromDateComponents = visibleDateComponents
        visibleDateComponents = toDateComponents

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        adapter.performUpdate()
        CATransaction.commit()
        
        updateContentOffset(animated: false)
        
        /// 日期变化回调
        didChangeVisibleDateComponents?(toDateComponents, fromDateComponents)
    }
    
    override func reloadData() {
        super.reloadData()
        updateContentOffset(animated: false)
    }
    
    override func reloadData(animateStyle: SlideStyle) {
        super.reloadData(animateStyle: animateStyle)
        updateContentOffset(animated: false)
    }
    
    /// 当前月份日期组件
    func setVisibleDateComponents(_ dateComponents: DateComponents, animated: Bool) {
        let animateStyle = SlideStyle.horizontalStyle(fromValue: visibleDateComponents.yearMonthDateComponents,
                                                        toValue: dateComponents.yearMonthDateComponents)
        self.visibleDateComponents = dateComponents
        self.reloadData(animateStyle: animateStyle)
    }
    
    // MARK: - Private Metehods
    /// 更新内容偏移
    func updateContentOffset(animated: Bool) {
        var index = kNearMonthsCount
        if let indexPath = adapter.indexPath(of: visibleDateComponents as NSDateComponents) {
            index = indexPath.item
        }

        /// 设置新偏移
        var offset = CGPoint.zero
        offset.x = bounds.width * CGFloat(index)
        collectionView.contentOffset = offset
    }
}
