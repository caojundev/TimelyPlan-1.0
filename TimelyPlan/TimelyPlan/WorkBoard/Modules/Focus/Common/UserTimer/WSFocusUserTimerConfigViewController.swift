//
//  WSFocusUserTimerConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

/// 用户计时器组件的配置界面。
///
/// 单区块：点击「已选计时器」进入计时器列表进行多选，
/// 选中的计时器按选择顺序展示在组件中，配置在用户操作后即时保存。
class WSFocusUserTimerConfigViewController: TPTableSectionsViewController,
                                            WSPluginConfigurable {
    
    private struct Config {
        
        /// 首个区块顶部间距
        static let firstSectionHeaderHeight = 5.0
        
        /// 单元格高度
        static let defaultCellHeight = 55.0
    }
    
    /// 正在配置的组件
    let plugin: WSPlugin
    
    /// 配置变化回调。由外部在展示前设置
    var didChangeConfigJSON: ((String?) -> Void)?
    
    /// 当前配置 JSON 字符串
    private(set) var configJSON: String?
    
    /// 当前配置
    private var configuration: WSFocusUserTimerConfiguration
    
    // MARK: - 已选计时器
    private lazy var timerSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = Config.firstSectionHeaderHeight
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [timerCellItem]
        return sectionController
    }()
    
    private lazy var timerCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.height = Config.defaultCellHeight
        cellItem.accessoryType = .disclosureIndicator
        cellItem.title = resGetString("Selected Timers")
        cellItem.subtitleConfig.font = .systemFont(ofSize: 10.0, weight: .medium)
        cellItem.updater = { [weak self] in
            guard let self = self else {
                return
            }
            
            let timers = self.selectedTimers
            let titles = timers.map { $0.displayName }.joined(separator: ", ")
            self.timerCellItem.subtitle = titles.isEmpty ? nil : titles
            self.timerCellItem.valueConfig = .valueText("\(timers.count)")
        }
        
        cellItem.didSelectHandler = { [weak self] in
            self?.editTimers()
        }
        
        return cellItem
    }()
    
    // MARK: - 初始化
    init(plugin: WSPlugin) {
        self.plugin = plugin
        self.configJSON = plugin.configJSON
        self.configuration = plugin.configuration(as: WSFocusUserTimerConfiguration.self)
            ?? WSFocusUserTimerConfiguration()
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Timer Options")
        preferredContentSize = AppLayout.Popover.extraLarge
        
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        setupActionsBar(actions: [doneAction])
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        sectionControllers = [timerSectionController]
        reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - 选择计时器
    /// 进入计时器列表选择要展示的计时器，支持多选
    private func editTimers() {
        let viewController = WSFocusUserTimerSelectionViewController(selectedIdentifiers: configuration.timerIdentifiers)
        viewController.didFinishSelection = { [weak self] identifiers in
            guard let self = self else {
                return
            }
            
            self.configuration.timerIdentifiers = identifiers
            self.saveConfiguration()
            self.adapter.reloadCell(forItem: self.timerCellItem, with: .none)
        }
        
        viewController.popoverShowAsNavigationRoot()
    }
    
    /// 已选计时器，按配置顺序排列。已被删除的计时器会被忽略
    private var selectedTimers: [FocusTimer] {
        let timers = FocusRepository.getActiveTimers() ?? []
        let timersByIdentifier = Dictionary(timers.map { ($0.identifier, $0) },
                                            uniquingKeysWith: { first, _ in first })
        return configuration.timerIdentifiers.compactMap { timersByIdentifier[$0] }
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
