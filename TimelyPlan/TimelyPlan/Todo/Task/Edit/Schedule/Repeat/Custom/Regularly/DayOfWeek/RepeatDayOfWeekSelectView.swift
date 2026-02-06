//
//  WeekdaySelectView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/5.
//

import Foundation
import UIKit

protocol RepeatDayOfWeekSelectViewDelegate: AnyObject {
    
    func daysOfWeekSelectView(_ view: RepeatDayOfWeekSelectView, canSelectWeekday weekday: Weekday) -> Bool

    func daysOfWeekSelectView(_ view: RepeatDayOfWeekSelectView, canDeselectWeekday weekday: Weekday) -> Bool
    
    func daysOfWeekSelectView(_ view: RepeatDayOfWeekSelectView, didDeselectWeekday weekday: Weekday)
    
    func daysOfWeekSelectView(_ view: RepeatDayOfWeekSelectView, didSelectWeekday weekday: Weekday)
}

class RepeatDayOfWeekSelectView: TPCollectionWrapperView,
                                    TPCollectionSingleSectionListDataSource,
                                    TPCollectionViewAdapterDelegate  {
    
    /// 条目内间距
    static let itemPadding = UIEdgeInsets(horizontal: 12.0)
    static let sectionInset = UIEdgeInsets(horizontal: 8.0, vertical: 10.0)
    static let lineSpacing = 8.0
    
    weak var delegate: RepeatDayOfWeekSelectViewDelegate?
    
    let weekdays = Weekday.allCases
    
    var selectedWeekdays: Set<Weekday> = []
    
    var titleFont = BOLD_SMALL_SYSTEM_FONT
    
    lazy var workdayCellStyle: TPCollectionCellStyle = {
        return .repeatDayCellStyle(with: Color(0x476AFF))
    }()

    lazy var weekendCellStyle: TPCollectionCellStyle = {
        return .repeatDayCellStyle(with: Color(0x34C759))
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.scrollDirection = .horizontal
        self.hideScrollIndicator()
        self.adapter.lineSpacing = Self.lineSpacing
        self.adapter.interitemSpacing = Self.lineSpacing
        self.adapter.dataSource = self
        self.adapter.delegate = self
        self.adapter.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - TPCollectionViewAdapterDataSource
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return weekdays.map{ $0.shortSymbol } as [NSString]
    }

    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Self.sectionInset
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionSize = adapter.collectionViewSize()
        let weekday = weekdays[indexPath.item]
        let title = weekday.shortSymbol
        let titleWidth = title.width(with: titleFont)
        let itemWidth = titleWidth + Self.itemPadding.horizontalLength
        let itemHeight = collectionSize.height - Self.sectionInset.verticalLength
        return CGSize(width: itemWidth, height: max(0.0, itemHeight))
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return TPDefaultInfoCollectionCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        cell.contentView.padding = Self.itemPadding
        let cell = cell as! TPDefaultInfoCollectionCell
        cell.titleConfig.font = titleFont
        cell.titleConfig.textAlignment = .center
        cell.titleConfig.selectedTextColor = .white
        
        let weekday = weekdays[indexPath.item]
        cell.title = weekday.shortSymbol
        if weekday.isWeekend {
            cell.cellStyle = weekendCellStyle
        } else {
            cell.cellStyle = workdayCellStyle
        }
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool {
        let weekday = weekdays[indexPath.item]
        return selectedWeekdays.contains(weekday)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        
        let weekday = weekdays[indexPath.item]
        if selectedWeekdays.contains(weekday) {
            let bCanDeselect = delegate?.daysOfWeekSelectView(self, canDeselectWeekday: weekday) ?? true
            if bCanDeselect {
                let _ = selectedWeekdays.remove(weekday)
                delegate?.daysOfWeekSelectView(self, didDeselectWeekday: weekday)
            }
        } else {
            let bCanSelect = delegate?.daysOfWeekSelectView(self, canSelectWeekday: weekday) ?? true
            if bCanSelect {
                selectedWeekdays.insert(weekday)
                delegate?.daysOfWeekSelectView(self, didSelectWeekday: weekday)
            }
        }
        
        adapter.updateCheckmarks()
    }
}

extension TPCollectionCellStyle {
    
    static func repeatDayCellStyle(with selectedBackgroundColor: UIColor) -> TPCollectionCellStyle {
        let style = TPCollectionCellStyle()
        style.borderWidth = 0.0
        style.cornerRadius = 10.0
        style.backgroundColor = .tertiarySystemGroupedBackground
        style.selectedBackgroundColor = selectedBackgroundColor
        return style
    }
}
