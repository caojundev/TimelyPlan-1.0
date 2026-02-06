//
//  TodoTagSelectViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/15.
//

import Foundation
import UIKit

class TodoTagSelectViewController: TPTableSectionsViewController,
                                    TodoTagProcessorDelegate,
                                    TPMultipleItemSelectionUpdater {
    
    /// 点击完成
    var didClickDone: (() -> Void)?

    /// 信息视图
    private let infoViewHeight = 40.0
    private lazy var infoView: TodoTagSelectInfoView = {
        let view = TodoTagSelectInfoView()
        view.backgroundColor = themeBackgroundColor
        return view
    }()
    
    /// 占位视图
    private lazy var placeholderView: TPDefaultPlaceholderView = {
        let view = TPDefaultPlaceholderView()
        view.isBorderHidden = true
        view.image = resGetImage("placeholder_hashTag_80")
        return view
    }()
    
    private let tagSectionController: TodoTagSelectSectionController
    
    private let selection: TPMultipleItemSelection<TodoTag>
    
    init(selection: TPMultipleItemSelection<TodoTag>) {
        self.selection = selection
        self.tagSectionController = TodoTagSelectSectionController(selection: selection)
        super.init(style: .grouped)
        selection.addUpdater(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateInfo()
        view.addSubview(infoView)
        setupActionsBar(actions: [doneAction])
        actionsBar?.backgroundColor = themeBackgroundColor
        adapter.cellStyle.backgroundColor = themeBackgroundColor
        
        tableView.placeholderView = placeholderView
        sectionControllers = [tagSectionController]
        adapter.reloadData()
        todo.addUpdater(self, for: .tag)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        infoView.width = view.width
        infoView.height = infoViewHeight
        infoView.bottom = actionsBar?.top ?? view.safeLayoutFrame().maxY
    }
    
    override func tableViewFrame() -> CGRect {
        var layoutFrame = view.safeLayoutFrame()
        layoutFrame.size.height = layoutFrame.height - infoViewHeight - actionsBarHeight
        return layoutFrame
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override func clickDone() {
        TPImpactFeedback.impactWithSoftStyle()
        UIResponder.resignCurrentFirstResponder()
        didClickDone?()
    }
    
    /// 更新选择信息视图
    private func updateInfo() {
        let format: String
        let selectedCount = selection.selectedItems.count
        if selectedCount > 1 {
            format = resGetString("%ld tags selected")
        } else {
            format = resGetString("%ld tag selected")
        }
        
        infoView.title = String(format: format, selectedCount)
    }
    
    // MARK: -  TPMultipleItemSelectionUpdater
    func multipleItemSelectionDidChange<T>(inserts: Set<T>?, deletes: Set<T>?) where T : Hashable {
        updateInfo()
    }

    // MARK: - TodoTagProcessorDelegate
    func didCreateTodoTag(_ tag: TodoTag) {
        adapter.performSectionUpdate(forSectionObject: tagSectionController) { _ in
            self.adapter.commitFocusAnimation(for: tag)
        }
    }
    
    func didDeleteTodoTag(_ tag: TodoTag) {
        adapter.performSectionUpdate(forSectionObject: tagSectionController)
    }
    
    func didUpdateTodoTag(_ tag: TodoTag) {
        adapter.reloadCell(forItems: [tag],
                           inSection: tagSectionController,
                           rowAnimation: .none,
                           animateFocus: true)
    }
    
    func didReorderTodoTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int) {
        
    }
}

private class TodoTagSelectInfoView: UIView {
    
    var title: String? {
        didSet {
            textLabel.text = title
        }
    }
    
    private let textLabel = TPLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        self.backgroundColor = .systemBackground
        self.padding = UIEdgeInsets(horizontal: 16.0, vertical: 5.0)
        textLabel.textAlignment = .center
        textLabel.font = BOLD_SMALL_SYSTEM_FONT
        textLabel.textColor = resGetColor(.title)
        addSubview(textLabel)
        addSeparator(position: .top)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel.frame = layoutFrame()
    }
}
