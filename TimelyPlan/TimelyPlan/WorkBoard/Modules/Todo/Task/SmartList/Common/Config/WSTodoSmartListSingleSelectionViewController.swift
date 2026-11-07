//
//  WSTodoSmartListSingleSelectionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

// MARK: - 单选列表

/// 待办智能清单单选列表。
///
/// 展示可选的智能清单，点击切换选中状态；再次点击已选智能清单可取消选择。
/// 已完成与废纸篓没有未完成任务，不参与选择。
class WSTodoSmartListSingleSelectionViewController: TPViewController,
                                                   TPGroupTableViewDelegate {
    
    /// 选择变化回调，取消选择时返回 nil
    var didChangeSelection: ((String?) -> Void)?
    
    /// 已选智能清单标识
    private(set) var selectedIdentifier: String?
    
    /// 可选的智能清单
    private var lists: [TodoSmartList] {
        return [.inbox, .myDay, .overdue, .today, .tomorrow, .upcoming]
    }
    
    /// 分组标识
    private let groupIdentifier = "WSTodoSmartListSingleSelectionGroup"
    
    /// 单元格样式
    private lazy var cellStyle: TPTableCellStyle = {
        let style = TPTableCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .tertiarySystemFill
        return style
    }()
    
    /// 智能清单列表视图
    private lazy var listView: TPGroupTableView = {
        let view = TPGroupTableView(frame: .zero, style: .insetGrouped)
        view.delegate = self
        return view
    }()
    
    /// 占位视图提供者
    private lazy var placeholderProvider: TPDefaultPlaceholderProvider = {
        let provider = TPDefaultPlaceholderProvider()
        provider.emptyTitle = resGetString("No Smart List")
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
        
        filterSelection()
        reloadList()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        listView.frame = view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - 数据
    /// 已不可选的智能清单不再保留在选中状态
    private func filterSelection() {
        guard let identifier = selectedIdentifier else {
            return
        }
        
        guard !lists.contains(where: { $0.identifier == identifier }) else {
            return
        }
        
        selectedIdentifier = nil
        didChangeSelection?(nil)
    }
    
    private func reloadList() {
        let group = WSTodoSmartListGroup(identifier: groupIdentifier)
        group.lists = lists
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
        return WSTodoSmartListSelectCell.self
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didDequeCell cell: UITableViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? WSTodoSmartListSelectCell else {
            return
        }
        
        cell.style = cellStyle
        cell.list = tableView.item(at: indexPath) as? TodoSmartList
    }
    
    func groupTableView(_ tableView: TPGroupTableView, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        guard let list = tableView.item(at: indexPath) as? TodoSmartList else {
            return false
        }
        
        return list.identifier == selectedIdentifier
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) {
        guard let list = tableView.item(at: indexPath) as? TodoSmartList else {
            return
        }
        
        selectedIdentifier = selectedIdentifier == list.identifier ? nil : list.identifier
        TPImpactFeedback.impactWithSoftStyle()
        tableView.updateCheckmarks()
        didChangeSelection?(selectedIdentifier)
    }
}

// MARK: - 分组

/// 智能清单单选列表的分组。
private class WSTodoSmartListGroup: NSObject, GroupRepresentable {
    
    /// 分组唯一标识
    let identifier: String
    
    /// 分组内智能清单
    var lists: [TodoSmartList]?
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    // MARK: - GroupRepresentable
    var items: [ListDiffable]? {
        return lists
    }
    
    // MARK: - ListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? WSTodoSmartListGroup else {
            return false
        }
        
        return identifier == other.identifier
    }
}

// MARK: - 列表单元格

/// 智能清单选择列表的单元格。左侧为智能清单图标，右侧为名称与对勾
private class WSTodoSmartListSelectCell: TPImageInfoTextValueTableCell {
    
    /// 对勾图标
    private lazy var checkmarkView: UIImageView = {
        let view = UIImageView()
        view.image = resGetImage("checkmark_24")
        view.isHidden = true
        return view
    }()
    
    var list: TodoSmartList? {
        didSet {
            infoView.title = list?.title
            imageConfig.color = list?.color ?? .primary
            imageContent = .withName(list?.iconName)
            setNeedsLayout()
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        
        /// 与待办选择列表一致：右侧展示对勾
        padding = UIEdgeInsets(right: 32.0)
        contentPadding = UIEdgeInsets(left: 16.0, right: 4.0)
        imageConfig.margins = UIEdgeInsets(right: 8.0)
        imageConfig.shouldRenderImageWithColor = true
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
