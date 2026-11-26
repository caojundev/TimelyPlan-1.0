//
//  WSTodoTagMultiSelectionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 多选列表

/// 待办标签多选列表。
///
/// 复用待办的标签选择视图展示全部标签，点击切换选中状态，超出上限的选择会被忽略；
/// 底部展示已选数量与已选标签，选择顺序即组件内的展示顺序。
class WSTodoTagMultiSelectionViewController: TPViewController,
                                            TodoTagSelectCollectionViewDelegate {
    
    /// 选择变化回调，按选择顺序返回标签标识
    var didChangeSelection: (([String]) -> Void)?
    
    /// 已选标签标识，保持选择顺序
    private(set) var selectedIdentifiers: [String]
    
    /// 最多可选择的标签数量
    private let maximumSelectionCount: Int
    
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
    
    /// 已选标签信息。按选择顺序展示，与组件内的展示顺序保持一致
    private lazy var infoView: WSTodoTagSelectInfoView = {
        let view = WSTodoTagSelectInfoView()
        view.maximumSelectionCount = maximumSelectionCount
        return view
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
        selectView.backgroundColor = .systemGroupedBackground
        infoView.backgroundColor = .systemGroupedBackground
        
        view.addSubview(selectView)
        view.addSubview(infoView)
        
        /// 标签增删改都会影响可选列表
        TodoRepository.addUpdater(self, for: .tag)
        loadTags()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        /// 已选信息贴底，标签列表相应缩短
        let infoHeight = infoView.sizeThatFits(CGSize(width: view.width,
                                                      height: .greatestFiniteMagnitude)).height
        selectView.frame = CGRect(x: 0.0,
                                  y: 0.0,
                                  width: view.width,
                                  height: max(view.height - infoHeight, 0.0))
        infoView.frame = CGRect(x: 0.0,
                                y: selectView.bottom,
                                width: view.width,
                                height: infoHeight)
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
    
    /// 已删除的标签不再保留在选中列表内
    private func filterSelection() {
        let validIdentifiers = Set(tags.map { $0.identifier })
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
    
    private func reloadData() {
        selectView.userTags = tags
        selectView.reloadData()
        
        placeholderProvider.state = .loaded
        selectView.updatePlaceholderView()
        
        updateInfoView()
    }
    
    /// 更新底部已选信息，按配置中的选择顺序展示
    private func updateInfoView() {
        let tagsByIdentifier = Dictionary(tags.map { ($0.identifier, $0) },
                                          uniquingKeysWith: { first, _ in first })
        infoView.tags = selectedIdentifiers.compactMap { tagsByIdentifier[$0] }
        view.setNeedsLayout()
    }
    
    // MARK: - TodoTagSelectCollectionViewDelegate
    func selectCollectionView(_ view: TodoTagSelectCollectionView, didSelectTag tag: TodoTag) {
        if let index = selectedIdentifiers.firstIndex(of: tag.identifier) {
            selectedIdentifiers.remove(at: index)
        } else {
            /// 超出上限时不再加入，给出重一点的反馈
            guard selectedIdentifiers.count < maximumSelectionCount else {
                TPImpactFeedback.impactWithRigidStyle()
                return
            }
            
            selectedIdentifiers.append(tag.identifier)
        }
        
        selectView.updateCheckmarks(for: [tag])
        updateInfoView()
        didChangeSelection?(selectedIdentifiers)
    }
    
    func selectCollectionView(_ view: TodoTagSelectCollectionView, isSelectedTag tag: TodoTag) -> Bool {
        return selectedIdentifiers.contains(tag.identifier)
    }
}

// MARK: - TodoTagProcessorDelegate

extension WSTodoTagMultiSelectionViewController: TodoTagProcessorDelegate {
    
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
