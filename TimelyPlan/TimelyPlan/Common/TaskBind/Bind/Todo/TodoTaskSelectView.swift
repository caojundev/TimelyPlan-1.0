//
//  TodoTaskSelectView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/29.
//

import Foundation
import UIKit

protocol TodoTaskSelectViewDelegate: AnyObject {
    
    func todoTaskSelectView(_ view: TodoTaskSelectView, didSelectTask task: TodoTask)
    
    func todoTaskSelectView(_ view: TodoTaskSelectView, isSelectedTask task: TodoTask) -> Bool
}

class TodoTaskSelectView: UIView,
                          TPTableViewAdapterDataSource,
                          TPTableViewAdapterDelegate,
                          TodoGroupHeaderViewDelegate {
    
    weak var delegate: TodoTaskSelectViewDelegate?
    
    /// 分组数组
    var groups: [TodoGroup]?

    /// 提供占位视图
    var placeholderProvider: TPPlaceholderProviding? {
        didSet {
            updatePlaceholderView()
        }
    }
   
    var layoutConfig = TodoTaskLayoutConfig() {
        didSet {
            layoutManager.config = layoutConfig
        }
    }
    
    var detailOption: TodoTaskDetailOption {
        get {
            return layoutManager.detailOption
        }
        
        set {
            layoutManager.detailOption = newValue
        }
    }
    
    /// 显示头视图高度
    var normalHeaderHeight = 50.0
    
    /// 显示详情
    let showDetail: Bool = false

    private let adapter = TPTableViewAdapter()
    
    /// 布局管理器
    private let layoutManager = TodoTaskLayoutManager()
    
    /// 集合视图
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: bounds, style: .insetGrouped)
        tableView.isPrefetchingEnabled = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelectionDuringEditing = true
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0,
                                                         y: 0.0,
                                                         width: 0.0,
                                                         height: 0.01))
        tableView.shouldShowPlaceholder = { [weak self] in
            return self?.shouldShowPlaceholder() ?? false
        }
        
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemGroupedBackground
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds
    }
    
    func setupSubviews() {
        adapter.dataSource = self
        adapter.delegate = self
        adapter.tableView = tableView
        addSubview(tableView)
    }

    /// 是否显示占位视图
    func shouldShowPlaceholder() -> Bool {
        guard adapter.objects.count > 0 else {
            return true
        }
        
        return false
    }
    
    func updatePlaceholderView() {
        self.tableView.placeholderView = placeholderProvider?.placeholderView()
    }
    
    /// 重新加载数据
    func reloadData() {
        updatePlaceholderView()
        layoutManager.removeAllLayouts()
        adapter.reloadData()
    }
    
    // MARK: - TPTableViewAdapterDataSource
    func sectionObjects(for adapter: TPTableViewAdapter) -> [ListDiffable]? {
        return groups
    }
    
    func adapter(_ adapter: TPTableViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        guard let group = sectionObject as? TodoGroup else {
            return nil
        }
        
        if isExpanded(group) {
            return group.tasks
        }
        
        return nil
    }
    
    // MARK: - TPTableViewAdapterDelegate
    func adapter(_ adapter: TPTableViewAdapter, didSelectRowAt indexPath: IndexPath) {
        guard let task = task(at: indexPath) else {
            return
        }
        
        delegate?.todoTaskSelectView(self, didSelectTask: task)
        adapter.updateCheckmarks()
    }
    
    func adapter(_ adapter: TPTableViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return TodoTaskSelectTableCell.self
    }
    
    func adapter(_ adapter: TPTableViewAdapter, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let task = task(at: indexPath) else {
            return 0.0
        }
        
        let layout = layout(for: task)
        return layout.height
    }

    func adapter(_ adapter: TPTableViewAdapter, didDequeCell cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? TodoTaskBaseTableCell, let task = task(at: indexPath) else {
            return
        }
        
        cell.layout = layout(for: task)
        cell.reloadData(animated: false)
    }
    
    func adapter(_ adapter: TPTableViewAdapter, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        guard let task = task(at: indexPath) else {
            return false
        }
        
        return delegate?.todoTaskSelectView(self, isSelectedTask: task) ?? false
    }
    
    // MARK: - HeaderView
    func adapter(_ adapter: TPTableViewAdapter, heightForHeaderInSection section: Int) -> CGFloat {
        return normalHeaderHeight
    }
    
    func adapter(_ adapter: TPTableViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        return TodoGroupNormalHeaderView.self
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didDequeHeader headerView: UITableViewHeaderFooterView, inSection section: Int) {
        guard let headerView = headerView as? TodoGroupNormalHeaderView,
              let group = adapter.object(at: section) as? TodoGroup else {
            return
        }
        
        headerView.delegate = self
        headerView.section = section
        headerView.title = group.title
        headerView.updateExpanded(animated: false)
        headerView.count = group.tasks?.count ?? 0
    }
    
    func adapter(_ adapter: TPTableViewAdapter, updateHeaderInSection section: Int) {
        guard let headerView = adapter.headerView(in: section) else {
            return
        }
        
        self.adapter(adapter, didDequeHeader: headerView, inSection: section)
    }
    
    // MARK: - TodoGroupSelectingHeaderViewDelegate
    func isExpandedGroupHeaderView(_ headerView: TodoGroupBaseHeaderView) -> Bool {
        guard let group = adapter.object(at: headerView.section) as? TodoGroup else {
            return true
        }
        
        return isExpanded(group)
    }
    
    func groupHeaderView(_ headerView: TodoGroupBaseHeaderView, canToggleExpandStateTo isExpanded: Bool) -> Bool {
        return true
    }
    
    func groupHeaderView(_ headerView: TodoGroupBaseHeaderView, didToggleExpand isExpanded: Bool) {
        guard let group = adapter.object(at: headerView.section) as? TodoGroup else {
            return
        }
        
        setExpended(isExpanded, for: group)
        adapter.performSectionUpdate(forSectionObject: group, rowAnimation: .fade)
    }

    // MARK: - Expansion
    private var collapsedStates = [String: Bool]()
    
    func isExpanded(_ group: TodoGroup) -> Bool {
        let isCollapsed = collapsedStates[group.identifier] ?? false
        return !isCollapsed
    }
    
    func setExpended(_ isExpended: Bool, for group: TodoGroup) {
        if isExpended {
            collapsedStates[group.identifier] = nil
        } else {
            collapsedStates[group.identifier] = true
        }
    }
    
    // MARK: - Helpers
    
    func task(at indexPath: IndexPath) -> TodoTask? {
        return adapter.item(at: indexPath) as? TodoTask
    }
    
    var layoutWidth: CGFloat {
        var width = bounds.width
        if tableView.style == .insetGrouped {
            width -= tableView.layoutMargins.horizontalLength
        }
        
        return width
    }
    
    private func layout(for task: TodoTask) -> TodoTaskInfoLayout {
        layoutManager.width = layoutWidth
        layoutManager.showDetail = showDetail
        layoutManager.config = layoutConfig
        return layoutManager.layout(for: task)
    }
    
}
