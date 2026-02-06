//
//  RepeatSpecificDateListView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/20.
//

import Foundation
import UIKit

class RepeatSpecificDateListView: TPCollectionWrapperView,
                                    TPCollectionSingleSectionListDataSource,
                                    TPCollectionViewAdapterDelegate,
                                    TPCollectionCellDelegate,
                                    TPCalendarDateSelectionUpdater {
    
    /// 单元格条目内间距
    let itemPadding = UIEdgeInsets(horizontal: 12.0)
    
    /// 单元格条目高度
    let itemHeight = 40.0
    
    /// 单元格最小宽度
    let minimumItemWidth = 60.0

    /// 点击日期回调
    var didClickDate: ((DateComponents) -> Void)?
    
    /// 提醒选择管理器
    var selection: TPCalendarMultipleDateSelection? {
        didSet {
            selection?.addUpdater(self)
        }
    }
    
    var titleFont = BOLD_SMALL_SYSTEM_FONT
    
    private lazy var placeholderView: UIView = {
        let view = TPDefaultPlaceholderView()
        view.padding = UIEdgeInsets(value: 2.0)
        view.titleColor = .separator
        view.isBorderHidden = false
        view.title = resGetString("No Date")
        return view
    }()
    
    private lazy var cellStyle: TPCollectionCellStyle = {
        let style = adapter.cellStyle
        style.cornerRadius = 8.0
        style.backgroundColor = Color(0xABABAB, 0.1)
        style.selectedBackgroundColor = Color(0xABABAB, 0.2)
        return style
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        hideScrollIndicator()
        collectionView.placeholderView = placeholderView
        scrollDirection = .horizontal
        
        adapter.cellClass = TPDefaultInfoCollectionCell.self
        adapter.cellStyle = cellStyle
        adapter.sectionInset = UIEdgeInsets(horizontal: 5.0)
        adapter.interitemSpacing = 5.0
        adapter.lineSpacing = 5.0
        adapter.dataSource = self
        adapter.delegate = self
        adapter.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CollectionListDataSource
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        guard let selection = selection else {
            return nil
        }
        
        let items = selection.selectedDates.sorted()
        return items as [NSDateComponents]
    }
    
    // MARK: - CollectionListDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = title(at: indexPath) ?? ""
        let titleWidth = title.width(with: titleFont)
        let width = max(titleWidth + itemPadding.horizontalLength, minimumItemWidth)
        return CGSize(width: width, height: itemHeight)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! TPDefaultInfoCollectionCell
        cell.delegate = self
        cell.padding = itemPadding
        cell.infoView.title = title(at: indexPath)
        cell.infoView.titleConfig.font = titleFont
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        
        let cell = adapter.cellForItem(at: indexPath) as! TPDefaultInfoCollectionCell
        cell.showMenu(with: [.delete])
        
        let date = adapter.item(at: indexPath) as! DateComponents
        didClickDate?(date)
    }
    
    func collectionCell(_ cell: TPCollectionCell, perfomMenuAction type: TPCollectionCell.MenuActionType) {
        guard let indexPath = adapter.indexPath(for: cell) else {
            return
        }
        
        let date = adapter.item(at: indexPath) as! DateComponents
        if type == .delete {
            selection?.deselectDate(date)
        }
    }
    
    // MARK: - TPCalendarDateSelectionUpdater
    func updateCalendar(forDates dates: [DateComponents]) {
        adapter.performUpdate()
        guard let selection = selection else {
            return
        }

        if let date = dates.first, selection.isSelectedDate(date) {
            scrollToAndCommitFocusAnimation(for: date)
        }
    }
    
    // MARK: - Helpers
    func title(at indexPath: IndexPath) -> String? {
        let dateComponents = adapter.item(at: indexPath) as! DateComponents
        return dateComponents.flexibleMonthDayString
    }
    
    public func scrollToAndCommitFocusAnimation(for date: DateComponents) {
        let date = date as NSDateComponents
        adapter.scrollToItem(date,
                             at: .centeredHorizontally,
                             animated: true) { [weak self] _ in
            self?.adapter.commitFocusAnimation(for: date)
        }
    }
}
