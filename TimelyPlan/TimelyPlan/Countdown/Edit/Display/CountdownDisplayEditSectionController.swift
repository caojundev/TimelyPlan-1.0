//
//  CountdownDisplayEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/18.
//

import Foundation
import UIKit

/// 倒数日显示方式编辑区块
/// 负责设置倒数日事项在“我的一天”与日历中的显示方式，
/// 数据变更时通过回调通知外部（由外部同步到数据模型）。
class CountdownDisplayEditSectionController: TPTableItemSectionController {
    
    struct Config {
        static let sectionTitleHeaderHeight = 50.0
        
        static let sectionHeaderPadding = UIEdgeInsets(top: 15.0,
                                                       left: 0.0,
                                                       bottom: 0.0,
                                                       right: 16.0)
        static let defaultCellHeight = 55.0
    }
    
    /// “我的一天”显示方式改变回调
    var onMyDayDisplayModeChanged: ((CountdownDisplayMode) -> Void)?
    
    /// 日历显示方式改变回调
    var onCalendarDisplayModeChanged: ((CountdownDisplayMode) -> Void)?
    
    /// 在“我的一天”中的显示方式
    var myDayDisplayMode: CountdownDisplayMode = .none
    
    /// 在日历中的显示方式
    var calendarDisplayMode: CountdownDisplayMode = .none
    
    // MARK: - 单元格
    /// “我的一天”显示方式
    lazy var myDayDisplayCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.height = Config.defaultCellHeight
        cellItem.accessoryType = .disclosureIndicator
        cellItem.imageName = "myDay_24"
        cellItem.title = resGetString("My Day")
        cellItem.updater = {
            guard let self = self else { return }
            self.myDayDisplayCellItem.valueConfig = .valueText(self.myDayDisplayMode.title)
        }
        
        cellItem.didSelectHandler = { [weak self] in
            self?.editMyDayDisplayMode()
        }
        
        return cellItem
    }()
    
    /// 日历显示方式
    lazy var calendarDisplayCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.height = Config.defaultCellHeight
        cellItem.accessoryType = .disclosureIndicator
        cellItem.imageName = "calendar_24"
        cellItem.title = resGetString("Calendar")
        cellItem.updater = {
            guard let self = self else { return }
            self.calendarDisplayCellItem.valueConfig = .valueText(self.calendarDisplayMode.title)
        }
        
        cellItem.didSelectHandler = { [weak self] in
            self?.editCalendarDisplayMode()
        }
        
        return cellItem
    }()
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            return [myDayDisplayCellItem, calendarDisplayCellItem]
        }
        
        set {}
    }
    
    override init() {
        super.init()
        self.headerItem.title = resGetString("Display")
        self.headerItem.height = Config.sectionTitleHeaderHeight
        self.headerItem.padding = Config.sectionHeaderPadding
        self.footerItem.height = 0.0
    }
    
    // MARK: - 我的一天
    /// 编辑“我的一天”显示方式
    private func editMyDayDisplayMode() {
        guard let cell = adapter?.cellForItem(myDayDisplayCellItem) else {
            return
        }
        
        editDisplayMode(from: cell,
                        current: myDayDisplayMode) { [weak self] mode in
            self?.changeMyDayDisplayMode(mode)
        }
    }
    
    /// 变更“我的一天”显示方式
    func changeMyDayDisplayMode(_ mode: CountdownDisplayMode) {
        myDayDisplayMode = mode
        onMyDayDisplayModeChanged?(mode)
        adapter?.reloadCell(forItem: myDayDisplayCellItem, with: .none)
    }
    
    // MARK: - 日历
    /// 编辑日历显示方式
    private func editCalendarDisplayMode() {
        guard let cell = adapter?.cellForItem(calendarDisplayCellItem) else {
            return
        }
        
        editDisplayMode(from: cell,
                        current: calendarDisplayMode) { [weak self] mode in
            self?.changeCalendarDisplayMode(mode)
        }
    }
    
    /// 变更日历显示方式
    func changeCalendarDisplayMode(_ mode: CountdownDisplayMode) {
        calendarDisplayMode = mode
        onCalendarDisplayModeChanged?(mode)
        adapter?.reloadCell(forItem: calendarDisplayCellItem, with: .none)
    }
    
    // MARK: - 显示方式
    /// 从指定单元格弹出显示方式菜单
    /// - Parameters:
    ///   - cell: 触发菜单的单元格
    ///   - mode: 当前显示方式
    ///   - didSelect: 选中显示方式回调
    private func editDisplayMode(from cell: UITableViewCell,
                                 current mode: CountdownDisplayMode,
                                 didSelect: @escaping (CountdownDisplayMode) -> Void) {
        let menu = CountdownDisplayModeMenuController(currentDisplayMode: mode)
        menu.didSelectDisplayMode = didSelect
        menu.show(from: cell)
    }
}
