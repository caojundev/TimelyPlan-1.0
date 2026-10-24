//
//  WSFocusUserTimerSelectionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

/// 用户计时器选择视图控制器。
///
/// 列表展示全部活动计时器，点击切换选中状态；底部标签展示已选数量与名称。
/// 点击完成回调按选择顺序排列的计时器标识。
class WSFocusUserTimerSelectionViewController: TPViewController, TPGroupTableViewDelegate {
    
    /// 选择完成回调，参数为按选择顺序排列的计时器标识
    var didFinishSelection: (([String]) -> Void)?
    
    /// 已选计时器标识，保持用户选择的顺序
    private(set) var selectedIdentifiers: [String]
    
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
        label.font = .boldSystemFont(ofSize: 13.0)
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
    init(selectedIdentifiers: [String]) {
        self.selectedIdentifiers = selectedIdentifiers
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Select Timers")
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
    /// 计时器数据变化
    private func timersChanged() {
        DispatchQueue.main.async {
            /// 已删除的计时器不再保留在选中列表中
            let timers = self.viewModel.timers ?? []
            let validIdentifiers = Set(timers.map { $0.identifier })
            self.selectedIdentifiers = self.selectedIdentifiers.filter { validIdentifiers.contains($0) }
            
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
        selectionCountLabel.text = names.isEmpty ? countText : "\(countText)\n\(names)"
    }
}
