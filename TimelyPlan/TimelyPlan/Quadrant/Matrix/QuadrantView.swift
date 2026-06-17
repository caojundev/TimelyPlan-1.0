//
//  QuadrantView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/26.
//

import Foundation
import UIKit

protocol QuadrantViewDelegate: AnyObject {

    /// 点击添加按钮
    func quadrantViewDidClickAdd(_ view: QuadrantView)

    /// 点击标题视图
    func quadrantViewDidTapTitleView(_ view: QuadrantView)
    
    func quadrantView(_ view: QuadrantView, didSelectTask task: TodoTask)
    
    func quadrantView(_ view: QuadrantView, didClickCheckboxForTask task: TodoTask)

    func quadrantView(_ view: QuadrantView, leadingSwipeActionsConfigurationForTask task: TodoTask, at indexPath: IndexPath) -> UISwipeActionsConfiguration?
    
    func quadrantView(_ view: QuadrantView, trailingSwipeActionsConfigurationForTask task: TodoTask, at indexPath: IndexPath) -> UISwipeActionsConfiguration?
    
    func quadrantViewWillBeginDragging(_ view: QuadrantView)
    
    func quadrantView(_ view: QuadrantView, willBeginEditingTask task: TodoTask)
}

class QuadrantView: UIView, QuadrantTitleViewDelegate {
    
    /// 代理对象
    weak var delegate: QuadrantViewDelegate?
    
    /// 标题位置
    var titlePosition: QuadrantTitlePosition = .top {
        didSet {
            if titleView.position != titlePosition {
                titleView.position = titlePosition
                setNeedsLayout()
            }
        }
    }
    
    var isHighlighted: Bool = false {
        didSet {
            guard isHighlighted != oldValue else {
                return
            }
            
            updateBorderStyle()
        }
    }
    
    /// 标题视图高度
    private let titleViewHeight = 40.0
    private lazy var titleView: QuadrantTitleView = {
        let view = QuadrantTitleView(quadrant: self.interactor.quadrant,
                                     position: titlePosition)
        view.delegate = self
        return view
    }()
    
    /// 列表视图
    private lazy var listView: TodoTaskListView = {
        let showDetail = self.interactor.showDetail
        let view = TodoTaskListView(frame: .zero, style: .grouped, showDetail: showDetail)
        view.hiddenHeaderHeight = 0.0
        view.backgroundColor = .secondarySystemGroupedBackground
        view.placeholderProvider = self.interactor.placeholderProvider
        view.shouldHideGroupHeader = true
        view.layoutConfig = .small
        view.detailOption = .all
        view.scrollsToTop = false
        view.delegate = self
        return view
    }()
    
    private var groups: [TodoGroup]?
    
    /// 当前象限
    var quadrant: Quadrant {
        return interactor.quadrant
    }
    
    let interactor: QuadrantHomeListInteractor
    
    init(interactor: QuadrantHomeListInteractor) {
        self.interactor = interactor
        super.init(frame: .zero)
        self.clipsToBounds = true
        self.layer.cornerRadius = 8.0
        self.backgroundColor = .secondarySystemGroupedBackground
        self.titlePosition = interactor.titlePosition
        self.setupSubviews()
        self.updateBorderStyle()
        self.interactor.didChangeGroups = { [weak self] change in
            self?.groupsChanged(change)
        }
        
        self.interactor.didChangeSetting = { [weak self] keyName in
            self?.settingChanged(keyName)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(titleView)
        addSubview(listView)
    }
    
    // MARK: - 分组改变
    private func groupsChanged(_ change: TodoTaskListChange? = nil) {
        var rowAnimation: UITableView.RowAnimation = .fade
        if change != nil {
            rowAnimation = .top
        }
        
        DispatchQueue.main.async {
            self.listView.groups = self.interactor.groups
            self.listView.performUpdate(with: rowAnimation)
        }
    }
    
    private func settingChanged(_ keyName: QuadrantSetting.Key) {
        if keyName == .showDetail {
            let showDetail = interactor.showDetail
            if listView.showDetail != showDetail {
                listView.setShowDetail(showDetail)
            }
        }
    }
    
    // MARK: - Update
    private func updateBorderStyle() {
        let color = self.interactor.quadrant.color
        if isHighlighted {
            self.layer.borderWidth = 2.0
            self.layer.borderColor = color.cgColor
        } else {
            self.layer.borderWidth = 1.0
            self.layer.borderColor = color.withAlphaComponent(0.1).cgColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleView.width = width
        titleView.height = titleViewHeight
        listView.width = width
        listView.height = height - titleViewHeight
        if titlePosition == .top {
            titleView.top = 0.0
            listView.top = titleViewHeight
        } else {
            listView.top = 0.0
            titleView.bottom = height
        }
    }
    
    func loadData() {
        self.interactor.setNeedsRefresh()
        self.interactor.loadGroups()
    }
    
    func reloadDataIfNeeded() {
        listView.reloadDataIfNeeded()
    }
    
    override func endEditing(_ force: Bool) -> Bool {
        return listView.endEditing(force)
    }
    
    func setCompleted(_ isCompleted: Bool,
                      for task: TodoTask,
                      completion: ((Bool) -> Void)? = nil) {
        listView.setCompleted(isCompleted, for: task, completion: completion)
    }
    
    func setProgress(_ progress: TodoEditProgress,
                     for task: TodoTask,
                     completion: ((Bool) -> Void)? = nil) {
        listView.setProgress(progress, for: task, completion: completion)
    }
    
    func cellForItem(at indexPath: IndexPath) -> UITableViewCell? {
        return listView.cellForRow(at: indexPath)
    }
    
    func indexPathForItem(at point: CGPoint) -> IndexPath? {
        let convertedPoint = self.convert(point, toViewOrWindow: listView)
        return listView.indexPathForRow(at: convertedPoint)
    }
    
    func task(at indexPath: IndexPath) -> TodoTask? {
        return listView.task(at: indexPath)
    }
    
    // MARK: - QuadrantTitleViewDelegate
    func quadrantTitleViewDidClickAdd(_ titleView: QuadrantTitleView) {
        delegate?.quadrantViewDidClickAdd(self)
    }
    
    func quadrantTitleViewDidTap(_ titleView: QuadrantTitleView) {
        TPImpactFeedback.impactWithSoftStyle()
        delegate?.quadrantViewDidTapTitleView(self)
    }
}

extension QuadrantView: TodoTaskListViewDelegate {

    func todoTaskListView(_ listView: TodoTaskListView, didSelectTask task: TodoTask) {
        delegate?.quadrantView(self, didSelectTask: task)
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, didClickCheckboxForTask task: TodoTask) {
        delegate?.quadrantView(self, didClickCheckboxForTask: task)
    }

    func todoTaskListView(_ listView: TodoTaskListView, leadingSwipeActionsConfigurationForTask task: TodoTask, at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return delegate?.quadrantView(self, leadingSwipeActionsConfigurationForTask: task, at: indexPath)
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, trailingSwipeActionsConfigurationForTask task: TodoTask, at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return delegate?.quadrantView(self, trailingSwipeActionsConfigurationForTask: task, at: indexPath)
    }
    
    func todoTaskListViewWillBeginDragging(_ listView: TodoTaskListView) {
        delegate?.quadrantViewWillBeginDragging(self)
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, willBeginEditingTask task: TodoTask) {
        delegate?.quadrantView(self, willBeginEditingTask: task)
    }
}
