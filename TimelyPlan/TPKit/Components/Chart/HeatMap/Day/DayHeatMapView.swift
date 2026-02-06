//
//  HeatMapView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/30.
//

import Foundation
import UIKit

protocol DayHeatMapViewDelegate: AnyObject {
    
    /// 获取分级索引
    func dayHeatMapView(_ view: DayHeatMapView, levelOnDate date: Date) -> Int
}

class DayHeatMapView: TPCollectionWrapperView,
                       TPCollectionViewAdapterDataSource,
                      TPCollectionViewAdapterDelegate,
                      TFSectionTitleFlowLayoutTitleProvider {
    
    weak var delegate: DayHeatMapViewDelegate?
    
    /// 当前日期
    var date: Date = Date()
    
    /// 区块内间距
    let sectionInset = UIEdgeInsets(top: 30.0, left: 5, bottom: 5, right: 5)
    
    /// 条目间距
    let itemMargin = 2.0
    
    /// 周符号视图
    let weekdaySymbolsView = TPWeekdaySymbolView(frame: .zero, style: .veryShort)
    
    /// 周符号宽度
    let weekdaySymbolsWidth: CGFloat = 36.0
    
    /// 周开始日
    let firstWeekday: Weekday = .sunday
    
    /// 月符号
    let monthSymbols = Date.monthSymbols
    
    /// 描述标签高度
    let descriptionLabelHeight: CGFloat = 20.0
    
    /// 描述标签
    let descriptionLabel = UILabel()

    /// 分级颜色
    lazy var levels: [HeatMapLevel] = {        
        return Self.defaultLevels()
    }()
    
    lazy var mapInfo: HeatMapInfo? = {
        return Self.defaultMapInfo()
    }()
    
    /// 默认分级颜色
    static func defaultLevels() -> [HeatMapLevel] {
        let colors = [kHeatMapNoneColor,
                      kHeatMapLevelColor.withAlphaComponent(0.1),
                      kHeatMapLevelColor.withAlphaComponent(0.4),
                      kHeatMapLevelColor.withAlphaComponent(0.7),
                      kHeatMapLevelColor]
        var levels = [HeatMapLevel]()
        for color in colors {
            let level = HeatMapLevel(color: color, info: nil)
            levels.append(level)
        }
        
        return levels
    }
    
    static func defaultMapInfo() -> HeatMapInfo {
        let mapInfo = HeatMapInfo(levels: defaultLevels())
        mapInfo.iconCanvasSize = mapInfo.iconSize
        mapInfo.leadingText = resGetString("Less")
        mapInfo.trailingText = resGetString("More")
        return mapInfo
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.hideScrollIndicator()
        
        /// 周符号视图
        weekdaySymbolsView.firstWeekday = firstWeekday
        weekdaySymbolsView.scrollDirection = .vertical
        addSubview(weekdaySymbolsView)
        
        /// 描述标签
        descriptionLabel.font = BOLD_SMALL_SYSTEM_FONT
        descriptionLabel.textColor = Color(light: 0x888888, dark: 0xAFAFAF, alpha: 0.6)
        addSubview(descriptionLabel)
        
        let flowLayout = TPSectionTitleFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.titleHeight = sectionInset.top
        flowLayout.titleProvider = self
        setCollectionViewLayout(flowLayout)
        
        adapter.cellStyle.cornerRadius = 4.0
        adapter.cellStyle.backgroundColor = .clear
        adapter.cellStyle.selectedBackgroundColor = .clear
        adapter.sectionInset = sectionInset
        adapter.lineSpacing = itemMargin
        adapter.interitemSpacing = itemMargin
        adapter.cellClass = HeatMapCell.self
        adapter.dataSource = self
        adapter.delegate = self
        reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        
        let weekdaySymbolsHeight = bounds.height - sectionInset.verticalLength - descriptionLabelHeight
        weekdaySymbolsView.frame = CGRect(x: 0,
                                          y: sectionInset.top,
                                          width: weekdaySymbolsWidth,
                                          height: weekdaySymbolsHeight)
        
        descriptionLabel.sizeToFit()
        descriptionLabel.height = descriptionLabelHeight
        descriptionLabel.right = layoutFrame.maxX
        descriptionLabel.bottom = layoutFrame.maxY
    }
    
    override func animatedContainerView(_ containerView: TPAnimatedContainerView, frameForContentView contentView: UIView) -> CGRect {
        let mapWidth = max(bounds.width - weekdaySymbolsWidth, 0.0)
        let mapHeight = max(bounds.height - descriptionLabelHeight, 0.0)
        let frame = CGRect(x: weekdaySymbolsWidth, y: 0, width: mapWidth, height: mapHeight)
        return frame
    }
    
    override func reloadData() {
        super.reloadData()
        self.descriptionLabel.attributed.text = mapInfo?.attributedInfo
    }
    
    /// 滚动到当前月份
    func scrollToCurrentMonth(animated: Bool) {
        guard let date = Date().yearMonthDayDate else {
            return
        }
        
        adapter.scrollToItem(date as NSDate, at: .centeredHorizontally, animated: animated)
    }
    
    // MARK: - TFSectionTitleFlowLayoutTitleProvider
    func sectionTitleFlowLayout(_ layout: TPSectionTitleFlowLayout, titleForSection section: Int) -> String? {
        return monthSymbols[section]
    }
    
    // MARK: - CollectionListDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return monthSymbols as [NSString]
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        let section = adapter.section(of: sectionObject)!
        let yearStartDate = date.startOfYear()
        let date = yearStartDate.dateByAddingMonths(section)!
        return date.calendarMonthDays(firstWeekday: firstWeekday) as [NSDate]
    }
    
    // MARK: - CollectionListDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionHeight = adapter.collectionViewSize().height - sectionInset.verticalLength
        let countPerColumn = 7.0
        let itemHeight = (collectionHeight - (countPerColumn - 1) * itemMargin) / countPerColumn
        return CGSize(width: itemHeight, height: itemHeight)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let date = adapter.item(at: indexPath) as! Date
        let cell = cell as! HeatMapCell
        cell.cellStyle = adapter.cellStyle
        guard date.month == indexPath.section + 1 else {
            cell.isHidden = true
            return
        }
        
        cell.isHidden = false
        let index = delegate?.dayHeatMapView(self, levelOnDate: date) ?? 0
        var level: HeatMapLevel?
        if index >= levels.count {
            level = levels.last
        } else if index < 0 {
            level = levels.first
        } else {
            level = levels[index]
        }
        
        cell.color = level?.color
    }
}

