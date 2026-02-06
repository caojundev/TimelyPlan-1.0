//
//  TFWeekdaySymbolView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/11.
//

import Foundation
import UIKit

class TPWeekdaySymbolView: TPCollectionWrapperView,
                                   TPCollectionSingleSectionListDataSource,
                                   TPCollectionViewAdapterDelegate {
    
    /// 文本颜色
    var textColor = Color(light: 0x000000, dark: 0xffffff, alpha: 0.6)
    
    /// 符号样式
    var style: WeekdaySymbolStyle
    
    /// 周开始日
    var firstWeekday: Weekday = .sunday
    
    convenience override init(frame: CGRect) {
        self.init(frame: frame, style: .veryShort)
    }
    
    init(frame: CGRect, style: WeekdaySymbolStyle) {
        self.style = style
        super.init(frame: frame)
        isUserInteractionEnabled = false
        hideScrollIndicator()
        scrollDirection = .horizontal
        adapter.cellStyle.backgroundColor = .clear
        adapter.dataSource = self
        adapter.delegate = self
        reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Data Source
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        let symbols = Date.weekdaySymbols(style: style, firstWeekday: firstWeekday.rawValue)
        return symbols as [NSString]
    }
    
    // MARK: - Delegate
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return TPDefaultInfoCollectionCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! TPDefaultInfoCollectionCell
        let symbol = adapter.item(at: indexPath) as? String
        cell.title = symbol?.uppercased()
        cell.titleConfig.textColor = textColor
        cell.titleConfig.font = UIFont.boldSystemFont(ofSize: 10.0)
        cell.titleConfig.textAlignment = .center
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = adapter.collectionViewSize()
        if scrollDirection == .horizontal {
            return CGSize(width: size.width / 7.0, height: size.height)
        } else {
            return CGSize(width: size.width, height: size.height / 7.0)
        }
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}
