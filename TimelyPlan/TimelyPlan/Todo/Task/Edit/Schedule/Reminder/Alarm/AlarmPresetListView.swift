//
//  AlarmPresetListView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/9.
//

import Foundation
import UIKit

class AlarmPresetListView: TPCollectionWrapperView,
                           TPCollectionSingleSectionListDataSource,
                           TPCollectionViewAdapterDelegate,
                           TPMultipleItemSelectionUpdater {
    
    /// 提醒日期
    var eventDate: Date?
    
    /// 预设提醒
    var alarms: [TaskAlarm] = []
    
    /// 选中提醒
    var selection: TPMultipleItemSelection<TaskAlarm>? {
        didSet {
            selection?.addUpdater(self)
        }
    }
    
    /// 每行显示提醒数目
    var alarmsCountPerRow: Int = 3

    /// 条目高度
    var itemHeight: CGFloat = 60.0
    
    /// 单元格内间距
    private var itemPadding = UIEdgeInsets(horizontal: 8.0)
    
    lazy var cellStyle: TPCollectionCellStyle = {
        let style = TPCollectionCellStyle()
        style.cornerRadius = 0.0
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .primary
        return style
    }()
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layout = TPGridsCollectionViewFlowLayout()
        setCollectionViewLayout(layout)
        
        hideScrollIndicator()
        adapter.cellClass = AlarmCollectionViewCell.self
        adapter.interitemSpacing = 0.0
        adapter.lineSpacing = 0.0
        adapter.sectionInset = .zero
        adapter.dataSource = self
        adapter.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let layout = collectionViewLayout as! TPGridsCollectionViewFlowLayout
        layout.layoutStyle.columsCount = alarmsCountPerRow
        layout.layoutStyle.toColum = alarmsCountPerRow - 1
        let rowsCount = AlarmPresetListView.rowsCount(totalItemsCount: alarms.count,
                                                      itemsCountPerRow: alarmsCountPerRow)
        layout.layoutStyle.rowsCount = rowsCount
        layout.layoutStyle.fromRow = 0
        layout.invalidateLayout()
    }
    
    // MARK: - CollectionListDataSource
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return alarms
    }
    
    // MARK: - CollectionListDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionSize = adapter.collectionViewSize()
        let width = collectionSize.width / CGFloat(alarmsCountPerRow)
        return CGSize(width: width, height: itemHeight)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! AlarmCollectionViewCell
        cell.padding = itemPadding
        cell.cellStyle = cellStyle
        cell.eventDate = eventDate
        let alarm = adapter.item(at: indexPath) as! TaskAlarm
        cell.alarm = alarm
        cell.isDisabled = !isAlarmEnabled(alarm)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool {
        guard let selection = selection else {
            return false
        }

        let alarm = adapter.item(at: indexPath) as! TaskAlarm
        return selection.isSelectedItem(alarm)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let alarm = adapter.item(at: indexPath) as! TaskAlarm
        return isAlarmEnabled(alarm)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        if let selection = selection {
            let alarm = adapter.item(at: indexPath) as! TaskAlarm
            selection.selectItem(alarm)
        }
    }
    
    // MARK: - TPMultipleItemSelectionUpdater
    func multipleItemSelectionDidChange<T>(inserts: Set<T>?, deletes: Set<T>?) where T : Hashable {
        adapter.updateCheckmarks()
        
        if let cells = adapter.visibleCells as? [AlarmCollectionViewCell] {
            for cell in cells {
                var isEnabled = true
                if let alarm = cell.alarm {
                    isEnabled = isAlarmEnabled(alarm)
                }
                
                cell.isDisabled = !isEnabled
            }
        }
    }

    private func isAlarmEnabled(_ alarm: TaskAlarm) -> Bool {
        guard let selection = selection else {
            return true
        }

        if selection.isSelectedItem(alarm) {
            return true
        }
        
        return selection.canSelectItem(alarm)
    }
    
    // MARK: - Helper Methods
    
    static func rowsCount(totalItemsCount: Int,
                          itemsCountPerRow: Int) -> Int {
        var rowsCount = totalItemsCount / itemsCountPerRow
        if totalItemsCount % itemsCountPerRow != 0 {
            rowsCount += 1
        }
        
        return rowsCount
    }
}
