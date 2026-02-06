//
//  TodoTaskQuickAddView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/20.
//

import Foundation
import UIKit

protocol TodoTaskQuickAddViewDelegate: AnyObject {
    /// 点击 send 按钮
    func todoTaskQuickAddViewDidClickSend(_ quickAddView: TodoTaskQuickAddView)
}

class TodoTaskQuickAddView: TPKeyboardAwareView,
                                TodoTaskQuickAddMenuViewDelegate {

    weak var delegate: TodoTaskQuickAddViewDelegate?

    /// 快速添加任务
    private(set) var editTask: TodoQuickAddTask

    /// 是否连续添加
    private var shouldAddContinuously: Bool = true

    /// 编辑视图
    private lazy var editView: TodoTaskQuickAddEditView = { [weak self] in
        let view = TodoTaskQuickAddEditView(frame: bounds)
        view.nameDidChange = { name in
            self?.editTask.name = name
            self?.updateSendButtonEnabled()
        }
        
        view.noteDidChange = { note in
            self?.editTask.note = note
        }
        
        view.contentSizeDidChange = {
            self?.updateContentSize()
        }
        
        return view
    }()
    
    /// 标签视图
    private lazy var tagView: TodoTaskQuickAddTagView = { [weak self] in
        let view = TodoTaskQuickAddTagView(frame: .zero)
        return view
    }()
    
    /// 菜单视图
    private lazy var menuView: TodoTaskQuickAddMenuView = { [weak self] in
        let view = TodoTaskQuickAddMenuView()
        view.delegate = self
        return view
    }()
    
    /// 发送视图
    private lazy var sendView: TodoTaskQuickAddSendView = { [weak self] in
        let view = TodoTaskQuickAddSendView(frame: .zero)
        view.didSelectList = { list in
            self?.editTask.list = list
        }
        
        view.didClickSend = { button in
            self?.clickSend(button)
        }
        
        return view
    }()

    /// 最大编辑视图高度
    let maximumEditViewHeight = 80.0
    
    /// 最小编辑视图高度
    let minimumEditViewHeight = 40.0
    
    let maximumTagViewHeight = 45.0
    
    /// 菜单栏高度
    let menuViewHeight = 45.0
    
    /// 发送视图高度
    let sendViewHeight = 45.0
    
    init(task: TodoQuickAddTask) {
        self.editTask = task.copy() as! TodoQuickAddTask
        super.init(frame: .zero)
        self.backgroundColor = .secondarySystemGroupedBackground
        self.padding = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 5.0, right: 10.0)
        self.addSubview(tagView)
        self.addSubview(editView)
        self.addSubview(menuView)
        self.addSubview(sendView)
        self.addSeparator(position: .top)
        reloadData()
        todo.addUpdater(self, for: [.list, .tag])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        editView.width = layoutFrame.width
        editView.height = editViewHeight()
        editView.origin = layoutFrame.origin
    
        tagView.width = layoutFrame.width
        tagView.height = tagViewHeight()
        tagView.top = editView.bottom
        tagView.left = layoutFrame.minX
        
        menuView.width = layoutFrame.width
        menuView.height = menuViewHeight
        menuView.top = tagView.bottom
        menuView.left = layoutFrame.minX
        
        sendView.width = layoutFrame.width
        sendView.height = sendViewHeight
        sendView.top = menuView.bottom
        sendView.left = layoutFrame.minX
    }
    
    private func editViewHeight() -> CGFloat {
        editView.layoutIfNeeded()
        var height = editView.contentSize.height
        clampValue(&height, minimumEditViewHeight, maximumEditViewHeight)
        return height
    }

    private func tagViewHeight() -> CGFloat {
        guard let tags = editTask.tags, tags.count > 0 else {
            return 0.0
        }
        
        tagView.layoutIfNeeded()
        let height = tagView.contentHeight
        return min(maximumTagViewHeight, height)
    }
    
    /// 更新内容尺寸
    private func updateContentSize() {
        var contentHeight = padding.verticalLength
        contentHeight += editViewHeight()
        contentHeight += tagViewHeight()
        contentHeight += menuViewHeight + sendViewHeight
        let contentSize = CGSize(width: .greatestFiniteMagnitude, height: contentHeight)
        if self.contentSize != contentSize {
            self.contentSize = contentSize
            self.setNeedsLayout()
        }
    }
    
    /// 更新发送按钮可用状态
    private func updateSendButtonEnabled() {
        sendView.isSendEnabled = editTask.isValid
    }
    
    private func updateSendView() {
        sendView.list = editTask.list
        updateSendButtonEnabled()
    }
    
    private func updateEditView() {
        editView.name = editTask.name
        editView.note = editTask.note
        editView.isNoteEditEnabled = editTask.isNoteEnabled
    }
    
    private func updateTagView() {
        tagView.tags = editTask.tags
    }
    
    private func reloadMenuView() {
        menuView.task = editTask
        menuView.reloadData()
    }
    
    private func reloadData() {
        reloadMenuView()
        updateEditView()
        updateTagView()
        updateSendView()
        updateContentSize()
    }
    
    // MARK: - 编辑
    func beginNameEditing() {
        editView.beginNameEditing()
    }
    
    func endEditing() {
        if isDescendantFirstResponder {
            UIResponder.resignCurrentFirstResponder()
        }
    }

    func reset(with task: TodoQuickAddTask) {
        editTask = task.copy() as! TodoQuickAddTask
        reloadData()
    }
    
    // MARK: - Event Response
    @objc private func clickSend(_ button: UIButton) {
        delegate?.todoTaskQuickAddViewDidClickSend(self)
    }
    
    // MARK: - TodoTaskQuickAddMenuViewDelegate
    func quickAddMenuView(_ menuView: TodoTaskQuickAddMenuView, didChangeTask newTask: TodoQuickAddTask, with actionType: TodoTaskQuickAddMenuActionType) {
        
        switch actionType {
        case .tag:
            updateTagView()
            updateContentSize()
        case .note:
            editView.isNoteEditEnabled = editTask.isNoteEnabled
            updateContentSize()
            guard editView.isNoteEditEnabled else {
                return
            }
            
            editView.beginNoteEditing()
        default:
            break
        }
    }
}

extension TodoTaskQuickAddView: TodoListProcessorDelegate,
                                TodoTagProcessorDelegate {
     
    // MARK: - TodoListProcessorDelegate
    func didUpdateTodoList(_ list: TodoList) {
        guard let selectedList = editTask.list else {
            return
        }
        
        if selectedList === list {
            sendView.updateListPicker()
        }
    }
    
    func didDeleteTodoList(_ list: TodoList, from folder: TodoFolder?) {
        guard let selectedList = editTask.list else {
            return
        }
        
        if list == selectedList {
            sendView.updateListPicker()
        }
    }
    
    // MARK: - TodoTagProcessorDelegate
    func didCreateTodoTag(_ tag: TodoTag) {
        /// 无操作
    }

    /// 删除标签
    func didDeleteTodoTag(_ tag: TodoTag) {
        if let _ = editTask.tags?.remove(tag) {
            selectedTagsDidChange()
        }
    }
    
    /// 更新标签
    func didUpdateTodoTag(_ tag: TodoTag) {
        guard let selectedTags = editTask.tags else {
            return
        }
        
        if selectedTags.contains(tag) {
            selectedTagsDidChange()
        }
    }

    /// 重新排序标签
    func didReorderTodoTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int) {
        guard fromIndex < tags.count else {
            return
        }
        
        let reorderedTag = tags[fromIndex]
        if let selectedTags = editTask.tags, selectedTags.contains(reorderedTag) {
            selectedTagsDidChange()
        }
    }
    
    private func selectedTagsDidChange() {
        reloadMenuView()
        updateTagView()
        updateContentSize()
    }
    
}
