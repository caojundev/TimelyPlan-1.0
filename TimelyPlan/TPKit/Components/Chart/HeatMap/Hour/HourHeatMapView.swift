//
//  HourHeatMapView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/12.
//

import Foundation
import UIKit

protocol HourHeatMapViewDelegate: AnyObject {
    
    /// 获取分级索引
    func hourHeatMapView(_ view: HourHeatMapView, levelForDateRange range: DateRange) -> Int
}

class HourHeatMapView: TPCollectionWrapperView,
                        TPCollectionViewAdapterDataSource,
                        TPCollectionViewAdapterDelegate,
                        TFSectionTitleFlowLayoutTitleProvider {
    
    /// 表示日期所在日
    var date: Date = .now
    
    weak var delegate: HourHeatMapViewDelegate?

    /// 条目间距
    let itemMargin = 4.0
    
    /// 区块内间距
    let sectionInset = UIEdgeInsets(top: 20.0, left: 8.0, bottom: 0.0, right: 0.0)
    
    /// 描述标签高度
    let descriptionLabelHeight: CGFloat = 40.0
    
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
                      kHeatMapLevelColor]
        var levels = [HeatMapLevel]()
        for color in colors {
            let level = HeatMapLevel(color: color, info: nil)
            levels.append(level)
        }
        
        return levels
    }
    
    static func defaultMapInfo() -> HeatMapInfo {
        let level = HeatMapLevel(color: kHeatMapLevelColor, info: resGetString("5 minutes"))
        let mapInfo = HeatMapInfo(levels: [level])
        return mapInfo
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.hideScrollIndicator()
        
        /// 描述标签
        descriptionLabel.font = BOLD_SMALL_SYSTEM_FONT
        descriptionLabel.textAlignment = .right
        descriptionLabel.textColor = Color(light: 0x888888, dark: 0xAFAFAF, alpha: 0.6)
        addSubview(descriptionLabel)
        
        let flowLayout = TPSectionTitleFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.titleHeight = sectionInset.top
        flowLayout.titleConfig.textAlignment = .left
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
        descriptionLabel.width = layoutFrame.width
        descriptionLabel.height = descriptionLabelHeight
        descriptionLabel.left = layoutFrame.minX
        descriptionLabel.bottom = layoutFrame.maxY
    }
    
    override func reloadData() {
        super.reloadData()
        self.descriptionLabel.attributed.text = mapInfo?.attributedInfo
    }
    
    override func animatedContainerView(_ containerView: TPAnimatedContainerView, frameForContentView contentView: UIView) -> CGRect {
        let mapHeight = max(bounds.height - descriptionLabelHeight, 0.0)
        let frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: mapHeight)
        return frame
    }
    
    /// 滚动到当前小时
    func scrollToCurrentHour(animated: Bool) {
        let hour = Date().hour
        let indexPath = IndexPath(item: 0, section: hour)
        adapter.scrollToItem(at: indexPath, scrollPosition: .centeredHorizontally, animated:animated)
    }
    
    // MARK: - TFSectionTitleFlowLayoutTitleProvider
    func sectionTitleFlowLayout(_ layout: TPSectionTitleFlowLayout, titleForSection section: Int) -> String? {
        if section % 2 == 0 {
            return String(format: "%02ld:00", section)
        } else {
            return nil
        }
    }
    
    // MARK: - CollectionListDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return Array(0..<HOURS_PER_DAY).map { "\($0)" } as [NSString]
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        let hour = sectionObject as! String
        var items = [String]()
        for i in 0..<12 {
            items.append("\(hour)-\(i)")
        }
        
        return items as [NSString]
    }
    
    // MARK: - 
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionHeight = adapter.collectionViewSize().height - sectionInset.verticalLength
        let countPerColumn = 6.0
        let itemHeight = (collectionHeight - (countPerColumn - 1) * itemMargin) / countPerColumn
        return CGSize(width: itemHeight, height: itemHeight)
    }
    
    func dateRange(at indexPath: IndexPath) -> DateRange {
        let offset = indexPath.section * SECONDS_PER_HOUR + indexPath.row * SECONDS_PER_MINUTE * 5
        let startDate = date.dateWithTimeOffset(offset)
        let endDate = startDate.dateByAddingMinutes(5)
        return DateRange(startDate: startDate, endDate: endDate)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! HeatMapCell
        cell.cellStyle = adapter.cellStyle
        cell.isHidden = false
        
        let dateRange = dateRange(at: indexPath)
        let index = delegate?.hourHeatMapView(self, levelForDateRange: dateRange) ?? 0
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

