//
//  HabitReasonTagEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/20.
//

import Foundation
import UIKit

class HabitReasonTagEditViewController: TPTableViewController,
                                   TPTableViewAdapterDataSource,
                                   TPTableViewAdapterDelegate,
                                    TPTableDragInsertReorderDelegate {

    /// 是否允许编辑
    var isEditingEnabled: Bool = true
    
    /// 是否隐藏选中控件
    var isCheckboxHidden: Bool = true
    
    /// 当前选中标签
    var selectedReasonTag: ReasonTag?
    
    /// 原因标签数组
    var reasonTags: [ReasonTag]
    
    /// 排序管理器
    private var reorder: TPTableDragInsertReorder?
    
    lazy var placeholderView: TPDefaultPlaceholderView = {
        let view = TPDefaultPlaceholderView()
        view.title = resGetString("No Tag")
        view.titleLabel.alpha = 0.2
        view.imageView.alpha = 0.6
        return view
    }()
    
    override init(style: UITableView.Style) {
        self.reasonTags = HabitReasonTagManager.getReasonTags()
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Reason Tag")
        
        self.tableView.separatorStyle = .none
        self.tableView.placeholderView = placeholderView
        let newAction = TPButtonAction(title: resGetString("New Tag")) { [weak self] action in
            self?.addReasonTag()
        }
        
        self.actionsBar?.actionsCountPerRow = 1
        self.setupActionsBar(actions: [newAction])
    
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.adapter.dataSource = self
        self.adapter.delegate = self
        self.adapter.reloadData()
        self.setupReorder()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.actionsBar?.backgroundColor = .systemGroupedBackground
    }
    
    override func tableViewFrame() -> CGRect {
        return CGRect(x: 0.0, y: 0.0, width: view.width, height: view.height - actionsBarHeight)
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    /// 初始化排序管理器
    private func setupReorder() {
        guard isEditingEnabled else {
            return
        }
        
        let reorder = TPTableDragInsertReorder(tableView: adapter.tableView)
        reorder.indicatorBackColor = Color(0xFFFFFF, 0.1)
        reorder.isEnabled = true
        reorder.delegate = self
        self.reorder = reorder
    }
    
    // MARK: - Data Source
    func sectionObjects(for adapter: TPTableViewAdapter) -> [ListDiffable]? {
        return ["ReasonTagSection" as NSString]
    }
    
    func adapter(_ adapter: TPTableViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return reasonTags
    }
    
    // MARK: - Delegate
    func adapter(_ adapter: TPTableViewAdapter, didSelectRowAt indexPath: IndexPath) {
        let tag = adapter.item(at: indexPath) as! ReasonTag
        editTag(tag)
    }
    
    func adapter(_ adapter: TPTableViewAdapter, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func adapter(_ adapter: TPTableViewAdapter, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func adapter(_ adapter: TPTableViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return HabitReasonTagTableCell.self
    }

    func adapter(_ adapter: TPTableViewAdapter, didDequeCell cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! HabitReasonTagTableCell
        cell.reasonTag = adapter.item(at: indexPath) as? ReasonTag
    }
    
    func adapter(_ adapter: TPTableViewAdapter, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        let reasonTag = adapter.item(at: indexPath) as! ReasonTag
        return reasonTag.isEqual(selectedReasonTag)
    }
    
    func adapter(_ adapter: TPTableViewAdapter, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !isEditingEnabled {
            return nil
        }
        
        ///< 编辑
        let tag = reasonTags[indexPath.row]
        let editAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            self.editTag(tag)
            completion(true)
        }
        
        editAction.backgroundColor = Color(0x0091FF)
        editAction.image = resGetImage("edit_24", color: .white)
        
        ///< 删除
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            self.deleteTag(tag)
            completion(true)
        }
                            
        deleteAction.image = resGetImage("trash_24", color: .white)
        
        var actions: [UIContextualAction]
        if reasonTags.count > 1 {
            actions = [deleteAction, editAction]
        } else {
            actions = [editAction]
        }
        
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    // MARK: - 标签操作
    func addReasonTag() {
        HabitReasonTagManager.editTag(type: .create, emoji: nil, reason: nil) { newEmoji, newReason in
            self.didCreateNewTag(emoji: String(newEmoji), reason: newReason)
        }
    }
    
    func editTag(_ tag: ReasonTag) {
        HabitReasonTagManager.editTag(type: .modify, emoji: tag.emoji, reason: tag.reason) { newEmoji, newReason in
            if tag.emoji == newEmoji, tag.reason == newReason {
                return
            }
            
            tag.emoji = newEmoji
            tag.reason = newReason
            self.saveReasonTags()
            self.adapter.reloadCell(forItem: tag, with: .automatic, focusAnimated: true)
        }
    }
    
    func deleteTag(_ tag: ReasonTag)  {
        let _ = reasonTags.remove(tag)
        adapter.performUpdate()
        saveReasonTags()
    }

    func saveReasonTags() {
        HabitReasonTagManager.saveReasonTags(reasonTags)
    }
    
    /// 点击新标签按钮
    func didCreateNewTag(emoji: String, reason: String) {
        let tag = ReasonTag(emoji: emoji, reason: reason)
        let scrollAndCommitFocusAnimation = {
            self.adapter.scrollToItem(tag, at: .middle, animated: true) { _ in
                self.adapter.commitFocusAnimation(for: tag)
            }
        }
        
        guard !(reasonTags.contains(tag)) else {
            scrollAndCommitFocusAnimation()
            return
        }
        
        /// 添加到顶部
        reasonTags.insert(tag, at: 0)
        adapter.performUpdate { _ in
            scrollAndCommitFocusAnimation()
        }
        
        saveReasonTags()
    }

    // MARK: - TPTableDragInsertReorderDelegate
    func tableDragReorder(_ reorder: TPTableDragReorder, canMoveRowAt indexPath: IndexPath) -> Bool {
        return isEditingEnabled
    }
    
    func tableDragReorder(_ reorder: TPTableDragReorder, willBeginAt indexPath: IndexPath) {
        UIResponder.resignCurrentFirstResponder()
        tableView.setEditing(false, animated: false)
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                canInsertRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableDragInsertReorder(_ reorder: TPTableDragInsertReorder,
                                inserRowTo targetIndexPath: IndexPath,
                                from sourceIndexPath: IndexPath,
                                depth: Int) -> IndexPath? {
        reasonTags.moveObject(fromIndex: sourceIndexPath.row, toIndex: targetIndexPath.row)
        saveReasonTags()
        adapter.moveRow(at: sourceIndexPath, to: targetIndexPath)
        return targetIndexPath
    }
}

class HabitReasonTagTableCell: TPDefaultInfoTableCell {
    
    var reasonTag: ReasonTag? {
        didSet {
            emojiLabel.text = reasonTag?.emoji
            title = reasonTag?.reason
        }
    }
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30.0)
        label.textAlignment = .center
        return label
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.leftView = emojiLabel
        self.leftViewSize = .size(12)
        self.leftViewMargins = UIEdgeInsets(right: 12.0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.emojiLabel.layer.backgroundColor = UIColor.tertiarySystemGroupedBackground.cgColor
        self.emojiLabel.layer.cornerRadius = self.leftViewSize.halfHeight
    }
}
