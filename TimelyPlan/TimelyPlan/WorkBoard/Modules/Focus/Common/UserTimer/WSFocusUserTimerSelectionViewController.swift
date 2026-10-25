//
//  WSFocusUserTimerSelectionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

/// 用户计时器组件的配置界面。
///
/// 列表展示全部活动计时器，点击切换选中状态；底部标签展示已选数量与名称。
/// 配置在用户操作后即时保存，点击完成关闭即可。
class WSFocusUserTimerSelectionViewController: TPViewController,
                                              TPGroupTableViewDelegate,
                                              WSPluginConfigurable {
    
    // MARK: - WSPluginConfigurable
    /// 正在配置的组件
    let plugin: WSPlugin
    
    /// 配置变化回调。由外部在展示前设置
    var didChangeConfigJSON: ((String?) -> Void)?
    
    /// 当前配置 JSON 字符串
    private(set) var configJSON: String?
    
    /// 当前配置
    private var configuration: WSFocusUserTimerConfiguration
    
    /// 已选计时器标识，保持用户选择的顺序
    private var selectedIdentifiers: [String]
    
    // MARK: - 子视图
    /// 计时器列表
    lazy var listView: TPGroupTableView = {
        let view = TPGroupTableView(frame: view.bounds, style: .insetGrouped)
        view.delegate = self
        return view
    }()
    
    /// 单元格样式
    lazy var cellStyle: TPTableCellStyle = {
        let style = TPTableCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .tertiarySystemFill
        return style
    }()
    
    /// 分组标识
    private let groupIdentifier = "FocusUserTimerSelectionGroup"
    
    /// 选中数量标签高度
    private let selectionCountLabelHeight: CGFloat = 36.0
    
    /// 选中数量标签
    lazy var selectionCountLabel: TPLabel = {
        let label = TPLabel()
        label.font = .boldSystemFont(ofSize: 11.0)
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.backgroundColor = themeBackgroundColor
        label.edgeInsets = UIEdgeInsets(horizontal: 16.0, top: 4.0)
        return label
    }()
    
    /// 计时器数据源
    private let viewModel = FocusUserTimerViewModel()
    
    // MARK: - 初始化
    init(plugin: WSPlugin) {
        let configuration = plugin.configuration(as: WSFocusUserTimerConfiguration.self)
            ?? WSFocusUserTimerConfiguration()
        
        self.plugin = plugin
        self.configJSON = plugin.configJSON
        self.configuration = configuration
        self.selectedIdentifiers = configuration.timerIdentifiers
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Timer Options")
        self.preferredContentSize = AppLayout.Popover.extraLarge
        
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        view.addSubview(listView)
        view.addSubview(selectionCountLabel)
        selectionCountLabel.addSeparator(position: .top)
        setupActionsBar(actions: [doneAction])
        
        let placeholderProvider = viewModel.placeholderProvider
        placeholderProvider.emptyTitle = resGetString("No Timer")
        listView.placeholderProvider = placeholderProvider
        
        viewModel.timersDidChange = { [weak self] _ in
            self?.timersChanged()
        }
        
        updateSelectionCount()
        viewModel.loadTimers()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        /// 选中数量标签位于操作栏上方，列表相应缩短
        var listFrame = contentFrame
        listFrame.size.height = max(listFrame.height - selectionCountLabelHeight, 0.0)
        self.listView.frame = listFrame
        self.selectionCountLabel.frame = CGRect(x: contentFrame.minX,
                                                y: listFrame.maxY,
                                                width: contentFrame.width,
                                                height: selectionCountLabelHeight)
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - 数据
    /// 计时器数据变化
    private func timersChanged() {
        DispatchQueue.main.async {
            /// 已删除的计时器不再保留在选中列表中
            let timers = self.viewModel.timers ?? []
            let validIdentifiers = Set(timers.map { $0.identifier })
            let filteredIdentifiers = self.selectedIdentifiers.filter { validIdentifiers.contains($0) }
            if filteredIdentifiers != self.selectedIdentifiers {
                self.selectedIdentifiers = filteredIdentifiers
                self.saveConfiguration()
            }
            
            self.updateSelectionCount()
            self.reloadList()
        }
    }
    
    /// 刷新列表
    private func reloadList() {
        let group = FocusTimerGroup(identifier: groupIdentifier)
        group.timers = viewModel.timers
        listView.groups = [group]
        listView.reloadData()
    }
    
    // MARK: - TPGroupTableViewDelegate
    func groupTableView(_ tableView: TPGroupTableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return MyDayFocusTimerBindCell.self
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didDequeCell cell: UITableViewCell, at indexPath: IndexPath) {
        let cell = cell as! MyDayFocusTimerBindCell
        cell.style = cellStyle
        cell.timer = tableView.item(at: indexPath) as? FocusTimer
    }
    
    func groupTableView(_ tableView: TPGroupTableView, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        guard let timer = tableView.item(at: indexPath) as? FocusTimer else {
            return false
        }
        
        return selectedIdentifiers.contains(timer.identifier)
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let timer = tableView.item(at: indexPath) as? FocusTimer else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        if let index = selectedIdentifiers.firstIndex(of: timer.identifier) {
            selectedIdentifiers.remove(at: index)
        } else {
            selectedIdentifiers.append(timer.identifier)
        }
        
        saveConfiguration()
        tableView.updateCheckmarks()
        updateSelectionCount()
    }
    
    // MARK: - 选中数量
    /// 更新选中数量与计时器名称。名称按选择顺序拼接在数量之后
    private func updateSelectionCount() {
        var timerMap = [String: FocusTimer]()
        let timers = viewModel.timers ?? []
        for timer in timers {
            timerMap[timer.identifier] = timer
        }
        
        let names = selectedIdentifiers.compactMap { timerMap[$0]?.displayName }.joined(separator: ", ")
        let countText = String(format: resGetString("%ld selected"), selectedIdentifiers.count)
        selectionCountLabel.text = names.isEmpty ? countText : "\(countText) \(names)"
    }
    
    // MARK: - 配置保存
    /// 合并并回调最新配置，由外部负责保存与刷新组件
    private func saveConfiguration() {
        configuration.timerIdentifiers = selectedIdentifiers
        
        let configJSON = WSPluginConfigJSONMerger.merging(base: configJSON, model: configuration)
        guard self.configJSON != configJSON else {
            return
        }
        
        self.configJSON = configJSON
        didChangeConfigJSON?(configJSON)
    }
}
