//
//  WSCountdownEventsSelectionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/23.
//

import Foundation
import UIKit

/// 倒数日多事项选择视图控制器
class WSCountdownEventsSelectionViewController: TPViewController, TPGroupTableViewDelegate {
    
    /// 选择完成回调，参数为按选择顺序排列的事项标识
    var didFinishSelection: (([String]) -> Void)?
    
    /// 已选事项标识，保持用户选择的顺序
    private(set) var selectedIdentifiers: [String]
    
    lazy var listView: TPGroupTableView = {
        let view = TPGroupTableView(frame: view.bounds, style: .insetGrouped)
        view.delegate = self
        return view
    }()
    
    lazy var cellStyle: TPTableCellStyle = {
        let style = TPTableCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .tertiarySystemFill
        return style
    }()
    
    /// 分组标识
    private let groupIdentifier = "CountdownEventsSelectionGroup"
    
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
    
    /// 数据源
    private let viewModel = CountdownEventSelectionViewModel()
    
    init(selectedIdentifiers: [String]) {
        self.selectedIdentifiers = selectedIdentifiers
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.stopObserving()
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Select Countdown")
        self.preferredContentSize = AppLayout.Popover.extraLarge
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        view.addSubview(listView)
        view.addSubview(selectionCountLabel)
        selectionCountLabel.addSeparator(position: .top)
        setupActionsBar(actions: [doneAction])
        
        let placeholderProvider = TPDefaultPlaceholderProvider()
        placeholderProvider.emptyImage = resGetImage("countdown_placeholder_80")
        placeholderProvider.emptyTitle = resGetString("No Countdown")
        listView.placeholderProvider = placeholderProvider
        
        viewModel.didChangeEvents = { [weak self] events in
            guard let self = self else {
                return
            }
            
            /// 已删除的事项不再保留在选中列表中
            let validIdentifiers = Set(events.map { $0.identifier })
            self.selectedIdentifiers = self.selectedIdentifiers.filter { validIdentifiers.contains($0) }
            self.updateSelectionCount()
            self.reloadList()
        }
        
        updateSelectionCount()
        viewModel.startObserving()
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
    
    /// 完成选择，回传当前选中内容并返回配置页
    override func clickDone() {
        didFinishSelection?(selectedIdentifiers)
        
        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - 数据
    /// 刷新列表
    private func reloadList() {
        let group = CountdownEventGroup(identifier: groupIdentifier)
        group.events = viewModel.events
        listView.groups = [group]
        listView.reloadData()
    }
    
    // MARK: - TPGroupTableViewDelegate
    func groupTableView(_ tableView: TPGroupTableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return CountdownEventBindCell.self
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didDequeCell cell: UITableViewCell, at indexPath: IndexPath) {
        let cell = cell as! CountdownEventBindCell
        cell.style = cellStyle
        cell.event = tableView.item(at: indexPath) as? CountdownEvent
    }
    
    func groupTableView(_ tableView: TPGroupTableView, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        guard let event = tableView.item(at: indexPath) as? CountdownEvent else {
            return false
        }
        
        return selectedIdentifiers.contains(event.identifier)
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let event = tableView.item(at: indexPath) as? CountdownEvent else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        if let index = selectedIdentifiers.firstIndex(of: event.identifier) {
            selectedIdentifiers.remove(at: index)
        } else {
            selectedIdentifiers.append(event.identifier)
        }
        
        tableView.updateCheckmarks()
        updateSelectionCount()
    }
    
    // MARK: - 选中数量
    /// 更新选中数量与事项名称。名称按选择顺序拼接在数量之后
    private func updateSelectionCount() {
        var eventMap = [String: CountdownEvent]()
        for event in viewModel.events {
            eventMap[event.identifier] = event
        }
        
        let names = selectedIdentifiers.compactMap { eventMap[$0]?.displayName }.joined(separator: ", ")
        let countText = String(format: resGetString("%ld selected"), selectedIdentifiers.count)
        selectionCountLabel.text = names.isEmpty ? countText : "\(countText) \(names)"
    }
}
