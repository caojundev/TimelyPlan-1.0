//
//  WSCountdownEventsConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/23.
//

import Foundation
import UIKit

/// 倒数日「事项」类组件的配置界面。
///
/// 区块列表样式：第一个区块配置事项来源（最近 / 自选），
/// 选中「自选」后追加事项选择区块，点击进入倒数日事项列表挑选。
/// 配置在用户操作后即时保存，无需额外的保存动作。
class WSCountdownEventsConfigViewController: TPTableSectionsViewController, WSPluginConfigurable {
    
    struct Config {
        /// 首个区块顶部间距
        static let firstSectionHeaderHeight = 5.0
        
        /// 其余区块顶部间距
        static let sectionHeaderHeight = 15.0
        
        /// 单元格高度
        static let defaultCellHeight = 55.0
        
        /// 菜单内容宽度
        static let menuContentWidth = 180.0
    }
    
    /// 正在配置的组件
    let plugin: WSPlugin
    
    /// 配置变化回调。由外部在展示前设置
    var didChangeConfigJSON: ((String?) -> Void)?
    
    /// 当前配置 JSON 字符串
    private(set) var configJSON: String?
    
    /// 当前配置
    private var configuration: WSCountdownEventsConfiguration
    
    // MARK: - 事项来源
    lazy var sourceSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = Config.firstSectionHeaderHeight
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [sourceCellItem]
        return sectionController
    }()
    
    lazy var sourceCellItem: TPFullSizeSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.cornerRadius = AppLayout.Cell.segmentedMenuCornerRadius
        cellItem.menuItems = WSCountdownEventsSource.segmentedMenuItems()
        cellItem.updater = { [weak self] in
            guard let self = self else { return }
            self.sourceCellItem.selectedMenuTag = self.configuration.source.tag
        }
        
        cellItem.didSelectMenuItem = { [weak self] menuItem in
            guard let source: WSCountdownEventsSource = menuItem.actionType() else {
                return
            }
            
            self?.selectSource(source)
        }
        
        return cellItem
    }()
    
    // MARK: - 事项
    lazy var eventSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = Config.sectionHeaderHeight
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [eventTypeCellItem]
        return sectionController
    }()
    
    /// 事项类型。仅最近事项可指定
    lazy var eventTypeCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.height = Config.defaultCellHeight
        cellItem.accessoryType = .disclosureIndicator
        cellItem.title = resGetString("Event Type")
        cellItem.updater = { [weak self] in
            guard let self = self else { return }
            let title = self.configuration.eventType?.title ?? resGetString("All")
            self.eventTypeCellItem.valueConfig = .valueText(title)
        }
        
        cellItem.didSelectHandler = { [weak self] in
            self?.editEventType()
        }
        
        return cellItem
    }()
    
    // MARK: - 自选事项
    lazy var eventCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.height = Config.defaultCellHeight
        cellItem.accessoryType = .disclosureIndicator
        cellItem.title = resGetString("Selected Event")
        cellItem.updater = { [weak self] in
            guard let self = self else { return }
            let events = self.selectedEvents
            let titles = events.map { $0.displayName }.joined(separator: ", ")
            self.eventCellItem.subtitle = titles.isEmpty ? nil : titles
            self.eventCellItem.valueConfig = .valueText("\(events.count)")
        }
        
        cellItem.didSelectHandler = { [weak self] in
            self?.editEvent()
        }
        
        return cellItem
    }()
    
    // MARK: - 初始化
    init(plugin: WSPlugin) {
        self.plugin = plugin
        self.configJSON = plugin.configJSON
        self.configuration = plugin.configuration(as: WSCountdownEventsConfiguration.self)
            ?? WSCountdownEventsConfiguration()
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Countdown Options")
        preferredContentSize = AppLayout.Popover.extraLarge
        
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        setupActionsBar(actions: [doneAction])
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        setupSectionControllers()
        reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - 区块
    /// 按当前来源刷新事项区块：最近事项展示类型行，自选事项展示选择行
    private func setupSectionControllers() {
        updateEventSectionController()
        sectionControllers = [sourceSectionController, eventSectionController]
    }
    
    private func updateEventSectionController() {
        eventSectionController.cellItems = configuration.source == .recent
            ? [eventTypeCellItem]
            : [eventCellItem]
    }
    
    // MARK: - 事项来源
    /// 选中事项来源
    private func selectSource(_ source: WSCountdownEventsSource) {
        guard configuration.source != source else {
            return
        }
        
        configuration.source = source
        saveConfiguration()
        updateEventSectionController()
        adapter.performUpdate(with: .fade)
    }
    
    // MARK: - 事项类型
    /// 弹出菜单选择事项类型，第一项「所有」表示不限类型
    private func editEventType() {
        guard let cell = adapter.cellForItem(eventTypeCellItem) else {
            return
        }
        
        let menuList = TPMenuListViewController()
        menuList.menuContentWidth = Config.menuContentWidth
        let menuItem = TPMenuItem.item(with: CountdownEventType.allCases,
                                       updater: { [weak self] type, action in
            action.title = type.emojiTitle
            action.handleBeforeDismiss = true
            action.isChecked = type == self?.configuration.eventType
        })
        
        /// 「所有」不在事项类型枚举内，以 nil 表示
        let allAction = TPMenuAction()
        allAction.identifier = "all"
        allAction.title = resGetString("All")
        allAction.handleBeforeDismiss = true
        allAction.isChecked = configuration.eventType == nil
        menuItem.actions = [allAction] + (menuItem.actions ?? [])
        
        menuList.didSelectMenuAction = { [weak self] action in
            if action.identifier == "all" {
                self?.selectEventType(nil)
                return
            }
            
            guard let type: CountdownEventType = action.actionType() else {
                return
            }
            
            self?.selectEventType(type)
        }
        
        menuList.menuItems = [menuItem]
        menuList.popoverShow(from: cell,
                             sourceRect: cell.bounds,
                             isSourceViewCovered: false,
                             preferredPosition: .bottomLeft,
                             permittedPositions: [.bottomLeft, .topLeft])
    }
    
    /// 选中事项类型。nil 表示不限类型
    private func selectEventType(_ eventType: CountdownEventType?) {
        guard configuration.eventType != eventType else {
            return
        }
        
        configuration.eventType = eventType
        saveConfiguration()
        adapter.reloadCell(forItem: eventTypeCellItem, with: .none)
    }
    
    // MARK: - 自选事项
    /// 进入倒数日事项列表选择要展示的事项，支持多选
    private func editEvent() {
        let vc = WSCountdownEventsSelectionViewController(selectedIdentifiers: configuration.eventIdentifiers)
        vc.didFinishSelection = { [weak self] identifiers in
            guard let self = self else {
                return
            }
            
            self.configuration.eventIdentifiers = identifiers
            self.saveConfiguration()
            self.adapter.reloadCell(forItem: self.eventCellItem, with: .none)
        }
        
        vc.popoverShowAsNavigationRoot()
    }
    
    /// 已选事项，按配置顺序排列。已被删除的事项会被忽略
    private var selectedEvents: [CountdownEvent] {
        return CountdownRepository.getEvents(withIdentifiers: configuration.eventIdentifiers)
    }
    
    // MARK: - 配置保存
    /// 合并并回调最新配置，由外部负责保存与刷新组件
    private func saveConfiguration() {
        let configJSON = WSPluginConfigJSONMerger.merging(base: configJSON, model: configuration)
        guard self.configJSON != configJSON else {
            return
        }
        
        self.configJSON = configJSON
        didChangeConfigJSON?(configJSON)
    }
}
