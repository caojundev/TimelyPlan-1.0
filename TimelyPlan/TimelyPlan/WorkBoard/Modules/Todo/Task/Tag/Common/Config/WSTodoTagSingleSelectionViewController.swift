//
//  WSTodoTagSingleSelectionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 单选列表

/// 待办标签单选列表。
///
/// 复用待办的标签选择视图展示全部标签，点击切换选中状态；
/// 再次点击已选标签可取消选择。
class WSTodoTagSingleSelectionViewController: TPViewController,
                                              TodoTagSelectCollectionViewDelegate {
    
    /// 选择变化回调，取消选择时返回 nil
    var didChangeSelection: ((String?) -> Void)?
    
    /// 已选标签标识
    private(set) var selectedIdentifier: String?
    
    /// 当前展示的标签
    private var tags: [TodoTag] = []
    
    /// 占位视图提供者
    private lazy var placeholderProvider: TPLoadableListPlaceholderProvider = {
        let provider = TPLoadableListPlaceholderProvider()
        provider.emptyImage = resGetImage("placeholder_hashTag_80")
        provider.emptyTitle = resGetString("No Tag")
        return provider
    }()
    
    /// 标签选择视图
    private lazy var selectView: TodoTagSelectCollectionView = {
        let view = TodoTagSelectCollectionView(frame: .zero)
        view.placeholderProvider = self.placeholderProvider
        view.delegate = self
        return view
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
        selectView.backgroundColor = .systemGroupedBackground
        view.addSubview(selectView)
        
        /// 标签增删改都会影响可选列表
        TodoRepository.addUpdater(self, for: .tag)
        loadTags()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        selectView.frame = view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - 数据
    private func loadTags() {
        TodoRepository.fetchTags { [weak self] tags in
            guard let self = self else {
                return
            }
            
            self.tags = tags ?? []
            self.filterSelection()
            self.reloadData()
        }
    }
    
    /// 已删除的标签不再保留在选中状态
    private func filterSelection() {
        guard let identifier = selectedIdentifier else {
            return
        }
        
        let identifiers = Set(tags.map { $0.identifier })
        guard !identifiers.isEmpty, !identifiers.contains(identifier) else {
            return
        }
        
        selectedIdentifier = nil
        didChangeSelection?(nil)
    }
    
    private func reloadData() {
        selectView.userTags = tags
        selectView.reloadData()
        
        placeholderProvider.state = .loaded
        selectView.updatePlaceholderView()
    }
    
    // MARK: - TodoTagSelectCollectionViewDelegate
    func selectCollectionView(_ view: TodoTagSelectCollectionView, didSelectTag tag: TodoTag) {
        selectedIdentifier = selectedIdentifier == tag.identifier ? nil : tag.identifier
        TPImpactFeedback.impactWithSoftStyle()
        view.updateCheckmarks(for: [tag])
        didChangeSelection?(selectedIdentifier)
    }
    
    func selectCollectionView(_ view: TodoTagSelectCollectionView, isSelectedTag tag: TodoTag) -> Bool {
        return selectedIdentifier == tag.identifier
    }
}

// MARK: - TodoTagProcessorDelegate

extension WSTodoTagSingleSelectionViewController: TodoTagProcessorDelegate {
    
    func didChangeRemoteTodoTag(with results: EntityChangeResults<TodoTag>?) {
        loadTags()
    }
    
    func didCreateTodoTag(_ tag: TodoTag) {
        loadTags()
    }
    
    func didDeleteTodoTag(_ tag: TodoTag) {
        loadTags()
    }
    
    func didUpdateTodoTag(_ tag: TodoTag, with editingTag: TodoEditingTag) {
        loadTags()
    }
    
    func didRecorderTodoTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int) {
        loadTags()
    }
}
