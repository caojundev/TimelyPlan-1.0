//
//  TodoTagSelectViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/15.
//

import Foundation
import UIKit

class TodoTagSelectViewController: TPViewController,
                                   TPMultipleItemSelectionUpdater,
                                    TodoTagSelectCollectionViewDelegate {
    
    /// 点击完成
    var didClickDone: (() -> Void)?

    /// 信息视图
    private lazy var infoView: TodoTagSelectInfoView = {
        let view = TodoTagSelectInfoView()
        return view
    }()
    
    /// 占位视图
    private lazy var placeholderProvider: TPLoadableListPlaceholderProvider = {
        let provider = TPLoadableListPlaceholderProvider()
        provider.emptyImage = resGetImage("placeholder_hashTag_80")
        return provider
    }()
    
    private lazy var selectView: TodoTagSelectCollectionView = {
        let view = TodoTagSelectCollectionView(frame: view.bounds)
        view.placeholderProvider = self.placeholderProvider
        view.delegate = self
        return view
    }()
    
    private let selection: TPMultipleItemSelection<TodoTag>
    
    private lazy var viewModel: TodoTagSelectViewModel = {
        let viewModel = TodoTagSelectViewModel()
        viewModel.onLoadTags = {[weak self] in
            self?.reloadData()
        }
        
        viewModel.onCreateTag = {[weak self] tag in
            self?.didCreateTodoTag(tag)
        }
        
        return viewModel
    }()
    
    init(selection: TPMultipleItemSelection<TodoTag>) {
        self.selection = selection
        super.init(nibName: nil, bundle: nil)
        selection.addUpdater(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(selectView)
        view.addSubview(infoView)
        setupActionsBar(actions: [doneAction])
        updateInfoView()
        viewModel.loadData()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let infoViewSize = infoView.sizeThatFits(CGSize(width: view.width, height: .greatestFiniteMagnitude))
        let layoutFrame = view.safeLayoutFrame()
        var selectViewFrame = view.bounds
        selectViewFrame.size.height = layoutFrame.height - infoViewSize.height - actionsBarHeight
        selectView.frame = selectViewFrame
        
        infoView.width = view.width
        infoView.height = infoViewSize.height
        infoView.bottom = actionsBar?.top ?? view.safeLayoutFrame().maxY
        infoView.backgroundColor = .secondarySystemGroupedBackground
        actionsBar?.backgroundColor = .secondarySystemGroupedBackground
        selectView.backgroundColor = .systemGroupedBackground
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickDone() {
        TPImpactFeedback.impactWithSoftStyle()
        UIResponder.resignCurrentFirstResponder()
        didClickDone?()
    }
    
    /// 更新选择信息视图
    private func updateInfoView() {
        self.infoView.tags = selection.selectedItems
        self.view.setNeedsLayout()
    }
    
    // MARK: -  TPMultipleItemSelectionUpdater
    func multipleItemSelectionDidChange<T>(inserts: Set<T>?, deletes: Set<T>?) where T : Hashable {
        var updateTags = Set<TodoTag>()
        if let inserts = inserts as? Set<TodoTag> {
            updateTags.formUnion(inserts)
        }
        
        if let deletes = deletes as? Set<TodoTag> {
            updateTags.formUnion(deletes)
        }
        
        selectView.updateCheckmarks(for: Array(updateTags))
        updateInfoView()
    }
    
    // MARK: - TodoTagSelectCollectionViewDelegate
    func selectCollectionView(_ view: TodoTagSelectCollectionView, didSelectTag tag: TodoTag) {
        selection.selectItem(tag, autoDeselect: true)
    }

    func selectCollectionView(_ view: TodoTagSelectCollectionView, isSelectedTag tag: TodoTag) -> Bool {
        return selection.isSelectedItem(tag)
    }
    
    // MARK: - TodoTagSelectViewModelDelegate
    func reloadData() {
        self.selectView.userTags = viewModel.tags
        self.selectView.reloadData()
        self.updatePlaceHolder()
    }
    
    func didCreateTodoTag(_ tag: TodoTag) {
        self.selectView.userTags = viewModel.tags
        self.selectView.performUpdate {[weak self] _ in
            self?.selectView.revealItem(tag, autoScroll: true)
        }
        
        self.updatePlaceHolder()
    }
    
    func updatePlaceHolder() {
        self.placeholderProvider.state = self.viewModel.state
        self.selectView.updatePlaceholderView()
    }
}
