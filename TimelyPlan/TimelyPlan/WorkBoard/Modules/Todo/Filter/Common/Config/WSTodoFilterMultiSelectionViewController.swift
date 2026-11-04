//
//  WSTodoFilterMultiSelectionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 多选列表

/// 待办过滤器多选列表。
///
/// 列表展示全部过滤器，点击切换选中状态，超出上限的选择会被忽略；
/// 底部标签展示已选数量与上限，选择顺序即组件内的展示顺序。
class WSTodoFilterMultiSelectionViewController: TPViewController,
                                               TPGroupTableViewDelegate {
    
    /// 选择变化回调，按选择顺序返回过滤器标识
    var didChangeSelection: (([String]) -> Void)?
    
    /// 已选过滤器标识，保持选择顺序
    private(set) var selectedIdentifiers: [String]
    
    /// 最多可选择的过滤器数量
    private let maximumSelectionCount: Int
    
    /// 分组标识
    private let groupIdentifier = "WSTodoFilterMultiSelectionGroup"
    
    /// 选中数量标签高度
    private let selectionCountLabelHeight: CGFloat = 36.0
    
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
    
    /// 选中数量标签
    private lazy var selectionCountLabel: TPLabel = {
        let label = TPLabel()
        label.font = .boldSystemFont(ofSize: 11.0)
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.backgroundColor = themeBackgroundColor
        label.edgeInsets = UIEdgeInsets(horizontal: 16.0, top: 4.0)
        return label
    }()
    
    init(selectedIdentifiers: [String], maximumSelectionCount: Int) {
        self.selectedIdentifiers = selectedIdentifiers
        self.maximumSelectionCount = max(maximumSelectionCount, 1)
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
        view.addSubview(selectionCountLabel)
        selectionCountLabel.addSeparator(position: .top)
        
        /// 过滤器增删改都会影响可选列表
        TodoRepository.addUpdater(self, for: .filter)
        
        updateSelectionCount()
        loadFilters()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        /// 选中数量标签位于底部，列表相应缩短
        var listFrame = view.bounds
        listFrame.size.height = max(listFrame.height - selectionCountLabelHeight, 0.0)
        listView.frame = listFrame
        selectionCountLabel.frame = CGRect(x: 0.0,
                                           y: listFrame.maxY,
                                           width: view.width,
                                           height: selectionCountLabelHeight)
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
    
    /// 已删除的过滤器不再保留在选中列表内
    private func filterSelection() {
        let validIdentifiers = Set(filters.map { $0.identifier })
        guard !validIdentifiers.isEmpty else {
            return
        }
        
        let filteredIdentifiers = selectedIdentifiers.filter { validIdentifiers.contains($0) }
        guard filteredIdentifiers != selectedIdentifiers else {
            return
        }
        
        selectedIdentifiers = filteredIdentifiers
        didChangeSelection?(filteredIdentifiers)
    }
    
    private func reloadList() {
        let group = WSTodoFilterGroup(identifier: groupIdentifier)
        group.filters = filters
        listView.groups = [group]
        listView.reloadData()
        
        updateSelectionCount()
    }
    
    // MARK: - 选中数量
    /// 更新已选数量与上限提示
    private func updateSelectionCount() {
        let countText = String(format: resGetString("%ld selected"), selectedIdentifiers.count)
        let maximumText = String(format: resGetString("Up to %ld"), maximumSelectionCount)
        selectionCountLabel.text = "\(countText) · \(maximumText)"
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
        
        return selectedIdentifiers.contains(filter.identifier)
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let filter = tableView.item(at: indexPath) as? TodoFilter else {
            return
        }
        
        if let index = selectedIdentifiers.firstIndex(of: filter.identifier) {
            selectedIdentifiers.remove(at: index)
            TPImpactFeedback.impactWithSoftStyle()
        } else {
            /// 超出上限时不再加入，给出重一点的反馈
            guard selectedIdentifiers.count < maximumSelectionCount else {
                TPImpactFeedback.impactWithRigidStyle()
                return
            }
            
            selectedIdentifiers.append(filter.identifier)
            TPImpactFeedback.impactWithSoftStyle()
        }
        
        tableView.updateCheckmarks()
        updateSelectionCount()
        didChangeSelection?(selectedIdentifiers)
    }
}

// MARK: - TodoFilterProcessorDelegate

extension WSTodoFilterMultiSelectionViewController: TodoFilterProcessorDelegate {
    
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

// MARK: - 分组

/// 过滤器多选列表的分组。
private class WSTodoFilterGroup: NSObject, GroupRepresentable {
    
    /// 分组唯一标识
    let identifier: String
    
    /// 分组内过滤器
    var filters: [TodoFilter]?
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    // MARK: - GroupRepresentable
    var items: [ListDiffable]? {
        return filters
    }
    
    // MARK: - ListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? WSTodoFilterGroup else {
            return false
        }
        
        return identifier == other.identifier
    }
}

// MARK: - 列表单元格

/// 过滤器多选列表的单元格。
private class WSTodoFilterSelectCell: TPColorInfoTextValueTableCell {
    
    /// 颜色竖条尺寸及其与名称的间距。与待办首页过滤器保持一致
    private let colorBarSize = CGSize(width: 6.0, height: 16.0)
    private let colorBarMargins = UIEdgeInsets(left: 12.0, right: 12.0)
    
    /// 对勾图标
    private lazy var checkmarkView: UIImageView = {
        let view = UIImageView()
        view.image = resGetImage("checkmark_24")
        view.isHidden = true
        return view
    }()
    
    var filter: TodoFilter? {
        didSet {
            let colorConfig = TPColorAccessoryConfig()
            colorConfig.size = colorBarSize
            colorConfig.margins = colorBarMargins
            colorConfig.color = filter?.color ?? TodoFilter.defaultColor
            self.colorConfig = colorConfig
            
            self.infoView.title = filter?.name ?? resGetString("Untitled")
            setNeedsLayout()
        }
    }
    
    override func setupInfoView() {
        super.setupInfoView()
        
        /// 与待办清单选择一致：右侧展示对勾
        infoView.rightAccessoryView = checkmarkView
        infoView.rightAccessorySize = .mini
        infoView.rightAccessoryMargins = UIEdgeInsets(left: 10.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkmarkView.updateImage(withColor: tintColor)
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkmarkView.isHidden = !checked
    }
}
