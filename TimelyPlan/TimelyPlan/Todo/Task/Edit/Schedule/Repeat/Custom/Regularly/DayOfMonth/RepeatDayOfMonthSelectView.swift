//
//  DaysOfMonthSelectView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/6.
//

import Foundation

class RepeatDayOfMonthSelectView: TPCollectionWrapperView,
                                     TPCollectionSingleSectionListDataSource,
                                     TPCollectionViewAdapterDelegate {
    
    /// 当前选中天
    var selectedDaysOfMonth: Set<Int> = []
    
    /// 选中天改变回调
    var didSelectDaysOfMonth: ((Set<Int>) -> Void)?
    
    /// 最小选中天数目
    var minimumSelectedDaysCount = 1
    
    /// 所有标题数组
    var titles: [String] = []
    
    /// 条目间距
    var itemMargin: CGFloat = 4.0
    
    /// 条目高度
    var itemHeight: CGFloat = 36.0
    
    private lazy var daysOfMonth: [Int] = {
        var days = [Int]()
        for i in 1...31 {
            days.append(i)
        }
        
        days.append(-1)
        return days
    }()
    
    lazy var normalCellStyle: TPCollectionCellStyle = {
        return .repeatDayCellStyle(with: Color(0x476AFF))
    }()
    
    lazy var lastDayCellStyle: TPCollectionCellStyle = {
        return .repeatDayCellStyle(with: Color(0x34C759))
    }()
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    convenience init(titles: [String]) {
        self.init(frame: .zero)
        self.titles = titles
        adapter.reloadData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        hideScrollIndicator()
        adapter.cellClass = TPDefaultInfoCollectionCell.self
        adapter.interitemSpacing = itemMargin
        adapter.lineSpacing = itemMargin
        adapter.dataSource = self
        adapter.delegate = self

        var symbols = [String]()
        for day in daysOfMonth {
            if day == -1 {
                symbols.append(resGetString("Last Day"))
            } else {
                symbols.append("\(day)")
            }
        }
        
        titles = symbols
        adapter.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - CollectionListDataSource
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return titles as [NSString]
    }
    
    // MARK: - CollectionListDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(value: itemMargin)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, interitemSpacingForSectionAt section: Int) -> CGFloat {
        return itemMargin
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionSize = adapter.collectionViewSize()
        let countPerRow = 7.0
        var itemWidth = floor((collectionSize.width - (countPerRow + 1) * itemMargin) / countPerRow)
        if isLastDay(at: indexPath) {
            itemWidth += itemWidth + itemMargin
        }
        
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! TPDefaultInfoCollectionCell
        cell.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        cell.titleConfig.textAlignment = .center
        cell.titleConfig.selectedTextColor = .white
        cell.title = adapter.item(at: indexPath) as? String
        if isLastDay(at: indexPath) {
            cell.cellStyle = lastDayCellStyle
        } else {
            cell.cellStyle = normalCellStyle
        }
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool {
        let day = daysOfMonth[indexPath.item]
        return selectedDaysOfMonth.contains(day)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
    
        let day = daysOfMonth[indexPath.item]
        if selectedDaysOfMonth.contains(day) {
            guard selectedDaysOfMonth.count > minimumSelectedDaysCount else {
                return
            }
            
            let _ = selectedDaysOfMonth.remove(day)
        } else {
            selectedDaysOfMonth.insert(day)
        }
        
        didSelectDaysOfMonth?(selectedDaysOfMonth)
        adapter.updateCheckmarks()
    }

    /// 是否是最后一天
    func isLastDay(at indexPath: IndexPath) -> Bool {
        let day = daysOfMonth[indexPath.item]
        return day == -1
    }
}
