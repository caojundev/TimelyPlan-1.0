//
//  AlarmScheduledListView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/10.
//

import Foundation
import UIKit

class AlarmListView: TPCollectionWrapperView,
                     TPCollectionSingleSectionListDataSource,
                     TPCollectionViewAdapterDelegate,
                     TPCollectionCellDelegate,
                     TPMultipleItemSelectionUpdater {
    
    var eventDate: Date?
    
    /// 单元格条目内间距
    let itemPadding = UIEdgeInsets(horizontal: 10.0)
    
    /// 单元格条目高度
    let itemHeight = 40.0
    
    /// 单元格最小宽度
    let minimumItemWidth = 60.0
    
    /// 点击提醒回调
    var didClickAlarm: ((TaskAlarm) -> Void)?
    
    /// 副标题是否隐藏
    var isSubtitleHidden: Bool = false
    
    /// 提醒选择管理器
    var selection: TPMultipleItemSelection<TaskAlarm>? {
        didSet {
            selection?.addUpdater(self)
        }
    }
    
    /// 是否可以编辑
    var editingEnabled: Bool = false
    
    var titleFont = BOLD_SMALL_SYSTEM_FONT
    
    var subtitleFont = UIFont.systemFont(ofSize: 9.0)
    
    private lazy var placeholderView: UIView = {
        let view = TPDefaultPlaceholderView()
        view.titleColor = Color(0x888888, 0.6)
        view.title = resGetString("No Alarm")
        view.isBorderHidden = true
        return view
    }()
    
    lazy var cellStyle: TPCollectionCellStyle = {
        let style = TPCollectionCellStyle()
        style.cornerRadius = 8.0
        style.backgroundColor = .tertiarySystemGroupedBackground
        return style
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        hideScrollIndicator()
        scrollDirection = .horizontal
        collectionView.placeholderView = placeholderView
        adapter.cellClass = AlarmCollectionViewCell.self
        adapter.sectionInset = UIEdgeInsets(horizontal: 8.0)
        adapter.interitemSpacing = 8.0
        adapter.lineSpacing = 8.0
        adapter.dataSource = self
        adapter.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CollectionListDataSource
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        
        guard let selection = selection else {
            return nil
        }
        let items = selection.selectedItems.sorted()
        return items
    }
    
    // MARK: - CollectionListDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let alarm = adapter.item(at: indexPath) as! TaskAlarm
        let title = alarm.attributedTitle(for: eventDate)?.value
        let subtitle = alarm.attributedSubtitle(for: eventDate)?.value
        let titleWidth = title?.width(with: titleFont) ?? 0.0
        let subtitleWidth = subtitle?.width(with: subtitleFont) ?? 0.0
        let width = max(titleWidth, subtitleWidth) + itemPadding.horizontalLength
        let height = itemHeight
        return CGSize(width: max(width, minimumItemWidth), height: height)
    }

    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! AlarmCollectionViewCell
        cell.delegate = self
        cell.infoView.titleConfig.font = titleFont
        cell.infoView.titleConfig.textAlignment = .center
        cell.infoView.subtitleConfig.font = subtitleFont
        cell.infoView.subtitleConfig.textAlignment = .center
        
        cell.isSubtitleHidden = isSubtitleHidden
        cell.padding = itemPadding
        cell.cellStyle = cellStyle
        cell.alarm = adapter.item(at: indexPath) as? TaskAlarm
        cell.eventDate = eventDate
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        if editingEnabled {
            let cell = adapter.cellForItem(at: indexPath) as! AlarmCollectionViewCell
            cell.showMenu(with: [.delete])
        }
        
        let alarm = adapter.item(at: indexPath) as! TaskAlarm
        didClickAlarm?(alarm)
    }
    
    func collectionCell(_ cell: TPCollectionCell, perfomMenuAction type: TPCollectionCell.MenuActionType) {
        guard let indexPath = adapter.indexPath(for: cell) else {
            return
        }
        
        let alarm = adapter.item(at: indexPath) as! TaskAlarm
        if type == .delete {
            selection?.deselectItem(alarm)
        }
    }

    // MARK: - TPMultipleItemSelectionUpdater
    func multipleItemSelectionDidChange<T>(inserts: Set<T>?, deletes: Set<T>?) where T : Hashable {
        adapter.performUpdate()
        
        guard let selection = selection, let alarms = inserts as? [TaskAlarm] else {
            return
        }

        if let alarm = alarms.first, selection.isSelectedItem(alarm) {
            scrollToAndCommitFocusAnimation(for: alarm)
        }
    }
    
    public func scrollToAndCommitFocusAnimation(for alarm: TaskAlarm) {
        adapter.scrollToItem(alarm,
                             at: .centeredHorizontally,
                             animated: true) { [weak self] _ in
            self?.adapter.commitFocusAnimation(for: alarm)
        }
    }
}


class AlarmCollectionCellItem: TPCollectionCellItem {
    
    let alarm: TaskAlarm
    
    var eventDate: Date?
    
    init(alarm: TaskAlarm) {
        self.alarm = alarm
        super.init()
        self.registerClass = AlarmCollectionViewCell.self
        self.contentPadding = UIEdgeInsets(horizontal: 8.0)
        self.scaleWhenHighlighted = false
    }
}

class AlarmCollectionViewCell: TPDefaultInfoCollectionCell {
    
    /// 任务日期
    var eventDate: Date? {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 闹铃
    var alarm: TaskAlarm? {
        didSet {
            setNeedsLayout()
        }
    }

    /// 副标题是否隐藏
    var isSubtitleHidden: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            guard let cellItem = cellItem as? AlarmCollectionCellItem else {
                return
            }
            
            alarm = cellItem.alarm
            eventDate = cellItem.eventDate
            setNeedsLayout()
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        titleConfig.font = BOLD_SYSTEM_FONT
        titleConfig.textAlignment = .center
        titleConfig.selectedTextColor = .white
        
        subtitleConfig.font = UIFont.boldSystemFont(ofSize: 10.0)
        subtitleConfig.textAlignment = .center
        subtitleConfig.selectedTextColor = .white
        scaleWhenHighlighted = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateTitle()
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        setNeedsLayout()
    }
    
    func updateTitle() {
        let badgeColor: UIColor?
        if isChecked {
            badgeColor = infoView.titleConfig.selectedTextColor
        } else {
            badgeColor = infoView.titleConfig.textColor
        }
        
        infoView.title = alarm?.attributedTitle(for: eventDate, badgeColor: badgeColor ?? .secondaryLabel)
        
        if isSubtitleHidden {
            infoView.subtitle = nil
        } else {
            infoView.subtitle = alarm?.attributedSubtitle(for: eventDate)
        }
    }
}
