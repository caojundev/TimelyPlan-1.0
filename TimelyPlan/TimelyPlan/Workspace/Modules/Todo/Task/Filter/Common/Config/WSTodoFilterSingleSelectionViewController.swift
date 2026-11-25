//
//  WSTodoFilterSingleSelectionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 单选列表

/// 待办过滤器单选列表。
///
/// 列表展示全部过滤器，点击切换选中状态；再次点击已选过滤器可取消选择。
class WSTodoFilterSingleSelectionViewController: TPViewController,
                                                TPGroupTableViewDelegate {
    
    /// 选择变化回调，取消选择时返回 nil
    var didChangeSelection: ((String?) -> Void)?
    
    /// 已选过滤器标识
    private(set) var selectedIdentifier: String?
    
    /// 分组标识
    private let groupIdentifier = "WSTodoFilterSingleSelectionGroup"
    
    /// 当前展示的过滤器
    private var filters: [TodoFilter] = []
    
    /// 单元格样式
    private lazy var cellStyle: TPTableCellStyle = {
        let style = TPTableCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .tertiarySystemFill
        return style
    }()
    
    /// 过滤器列表视图
    private lazy var listView: TPGroupTableView = {
        let view = TPGroupTableView(frame: .zero, style: .insetGrouped)
        view.delegate = self
        return view
    }()
    
    /// 占位视图提供者
    private lazy var placeholderProvider: TPDefaultPlaceholderProvider = {
        let provider = TPDefaultPlaceholderProvider()
        provider.emptyTitle = resGetString("No Filter")
        return provider
    }()
    
    init(selectedIdentifier: String?) {
        self.selectedIdentifier = selectedIdentifier
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        listView.placeholderProvider = placeholderProvider
        view.addSubview(listView)
        
        /// 过滤器增删改都会影响可选列表
        TodoRepository.addUpdater(self, for: .filter)
        loadFilters()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        listView.frame = view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - 数据
    private func loadFilters() {
        TodoRepository.fetchFilters { [weak self] filters in
            guard let self = self else {
                return
            }
            
            self.filters = filters ?? []
            self.filterSelection()
            self.reloadList()
        }
    }
    
    /// 已删除的过滤器不再保留在选中状态
    private func filterSelection() {
        guard let identifier = selectedIdentifier else {
            return
        }
        
        let identifiers = Set(filters.map { $0.identifier })
        guard !identifiers.isEmpty, !identifiers.contains(identifier) else {
            return
        }
        
        selectedIdentifier = nil
        didChangeSelection?(nil)
    }
    
    private func reloadList() {
        let group = WSTodoFilterGroup(identifier: groupIdentifier)
        group.filters = filters
        listView.groups = [group]
        listView.reloadData()
    }
    
    // MARK: - TPGroupTableViewDelegate
    func groupTableView(_ tableView: TPGroupTableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return WSTodoFilterSelectCell.self
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didDequeCell cell: UITableViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? WSTodoFilterSelectCell else {
            return
        }
        
        cell.style = cellStyle
        cell.filter = tableView.item(at: indexPath) as? TodoFilter
    }
    
    func groupTableView(_ tableView: TPGroupTableView, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        guard let filter = tableView.item(at: indexPath) as? TodoFilter else {
            return false
        }
        
        return filter.identifier == selectedIdentifier
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let filter = tableView.item(at: indexPath) as? TodoFilter else {
            return
        }
        
        selectedIdentifier = selectedIdentifier == filter.identifier ? nil : filter.identifier
        TPImpactFeedback.impactWithSoftStyle()
        tableView.updateCheckmarks()
        didChangeSelection?(selectedIdentifier)
    }
}

// MARK: - TodoFilterProcessorDelegate

extension WSTodoFilterSingleSelectionViewController: TodoFilterProcessorDelegate {
    
    func didChangeRemoteTodoFilter(with results: EntityChangeResults<TodoFilter>?) {
        loadFilters()
    }
    
    func didCreateTodoFilter(_ filter: TodoFilter) {
        loadFilters()
    }
    
    func didDeleteTodoFilter(_ filter: TodoFilter) {
        loadFilters()
    }
    
    func didUpdateTodoFilter(_ filter: TodoFilter, with editingFilter: TodoEditingFilter) {
        loadFilters()
    }
    
    func didReorderTodoFilter(in filters: [TodoFilter], fromIndex: Int, toIndex: Int) {
        loadFilters()
    }
}
