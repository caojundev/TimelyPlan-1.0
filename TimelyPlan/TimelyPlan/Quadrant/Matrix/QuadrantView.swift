//
//  QuadrantView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/26.
//

import Foundation
import UIKit

protocol QuadrantViewDelegate: AnyObject {
    
    /// 获取象限视图对应的数据获取器
    func fetcherForQuadrantView(_ view: QuadrantView) -> QuadrantFetcher?
    
    func quadrantView(_ view: QuadrantView, didSelectTask task: TodoTask)
    
    func quadrantView(_ view: QuadrantView, didClickCheckboxForTask task: TodoTask)
    
    func quadrantView(_ view: QuadrantView, leadingSwipeActionsConfigurationForTask task: TodoTask) -> UISwipeActionsConfiguration?
    
    func quadrantView(_ view: QuadrantView, trailingSwipeActionsConfigurationForTask task: TodoTask) -> UISwipeActionsConfiguration?
    
    /// 点击添加按钮
    func quadrantViewDidClickAdd(_ view: QuadrantView)
    
    /// 点击标题视图
    func quadrantViewDidTapTitleView(_ view: QuadrantView)
    
    func quadrantViewWillBeginDragging(_ view: QuadrantView)
    
    func quadrantView(_ view: QuadrantView, willBeginEditingTask task: TodoTask)
}

class QuadrantView: UIView,
                    QuadrantTitleViewDelegate,
                    TodoTaskListViewDelegate {
    
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
    
    /// 显示详情
    private(set) var showDetail: Bool
    
    /// 标题视图高度
    private let titleViewHeight = 40.0
    private lazy var titleView: QuadrantTitleView = {
        let view = QuadrantTitleView(quadrant: quadrant, position: titlePosition)
        view.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapTitleView))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    /// 列表视图
    private lazy var listView: TodoTaskListView = {
        let view = TodoTaskListView(frame: .zero, style: .grouped, showDetail: showDetail)
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layoutConfig = .small
        view.detailOption = .all
        view.shouldHideGroupHeader = true
        view.delegate = self
        view.scrollsToTop = false
        
        let placeholderView = view.placeholderView
        placeholderView.title = resGetString("No Tasks")
        placeholderView.titleColor = .systemGray5
        placeholderView.titleLabel.font = BOLD_SMALL_SYSTEM_FONT
        placeholderView.image = resGetImage(quadrant.placeholderImageName)
        placeholderView.imageColor = .systemGray3
        return view
    }()
    
    private let requestManager = RequestManager()
    
    private var groups: [TodoGroup]?
    
    /// 当前象限
    let quadrant: Quadrant
    
    convenience init(quadrant: Quadrant, showDetail: Bool = true) {
        self.init(frame: .zero, quadrant: quadrant, showDetail: showDetail)
    }
    
    init(frame: CGRect, quadrant: Quadrant, showDetail: Bool = true) {
        self.quadrant = quadrant
        self.showDetail = showDetail
        super.init(frame: frame)
        self.clipsToBounds = true
        self.layer.cornerRadius = 8.0
        self.backgroundColor = .secondarySystemGroupedBackground
        self.setupSubviews()
        updateBorderStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupSubviews() {
        addSubview(titleView)
        addSubview(listView)
    }
    
    private func updateBorderStyle() {
        let color = quadrant.color
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
    
    override func endEditing(_ force: Bool) -> Bool {
        return listView.endEditing(force)
    }
    
    func indexPathForItem(at point: CGPoint) -> IndexPath? {
        let convertedPoint = self.convert(point, toViewOrWindow: listView)
        return listView.indexPathForRow(at: convertedPoint)
    }
    
    func cellForItem(at indexPath: IndexPath) -> UITableViewCell? {
        return listView.cellForRow(at: indexPath)
    }
    
    func task(at indexPath: IndexPath) -> TodoTask? {
        return listView.task(at: indexPath)
    }
    
    /// 设置是否显示详情
    func setShowDetail(_ showDetail: Bool) {
        self.showDetail = showDetail
        listView.setShowDetail(showDetail)
    }
    
    func didUpdate(with infos: [TodoTaskChangeInfo]) {
        listView.didUpdate(with: infos)
    }
    
    func didDeleteTasks(_ tasks: [TodoTask]) {
        listView.didDeleteTasks(tasks)
    }
    
    func reloadCell(for task: TodoTask) {
        listView.reloadCell(for: task)
    }
    
    // MARK: - 异步加载
    /// 异步重新加载数据
    func asyncReloadData() {
        asyncLoadGroups { isSuccess in
            if isSuccess {
                self.listView.reloadData()
            }
        }
    }
    
    /// 异步执行更新
    func asyncPerformUpdate(completion: ((Bool) -> Void)? = nil) {
        asyncLoadGroups { [weak self] isSuccess in
            if isSuccess {
                self?.listView.performUpdate()
            }
            
            completion?(isSuccess)
        }
    }
    
    private func asyncLoadGroups(completion: @escaping(Bool) -> Void) {
        let requestID = requestManager.executeRequest()
        guard let fetcher = delegate?.fetcherForQuadrantView(self) else {
            groups = nil
            completion(true)
            return
        }
        
        fetcher.fetchGroups { groups in
            guard self.requestManager.shouldProceed(with: requestID) else {
                completion(false)
                return
            }
            
            self.groups = groups
            completion(true)
        }
    }
    
    // MARK: - QuadrantTitleViewDelegate
    func quadrantTitleViewDidClickAdd(_ titleView: QuadrantTitleView) {
        delegate?.quadrantViewDidClickAdd(self)
    }
    
    // MARK: - Event Response
    @objc func didTapTitleView() {
        TPImpactFeedback.impactWithSoftStyle()
        delegate?.quadrantViewDidTapTitleView(self)
    }
    
    // MARK: - TodoTaskListViewDelegate
    func todoGroupsForTaskListView(_ listView: TodoTaskListView) -> [TodoGroup]? {
        return groups
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, didSelectTask task: TodoTask) {
        delegate?.quadrantView(self, didSelectTask: task)
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, didClickCheckboxForTask task: TodoTask) {
        delegate?.quadrantView(self, didClickCheckboxForTask: task)
    }

    func todoTaskListView(_ listView: TodoTaskListView, didChangeCollapsedForGroup group: TodoGroup) {
        
    }
    
    func todoTaskListViewDidChangeSelectedTasks(_ listView: TodoTaskListView) {
        
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, leadingSwipeActionsConfigurationForTask task: TodoTask) -> UISwipeActionsConfiguration? {
        return delegate?.quadrantView(self, leadingSwipeActionsConfigurationForTask: task)
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, trailingSwipeActionsConfigurationForTask task: TodoTask) -> UISwipeActionsConfiguration? {
        return delegate?.quadrantView(self, trailingSwipeActionsConfigurationForTask: task)
    }
    
    func todoTaskListViewWillBeginDragging(_ listView: TodoTaskListView) {
        delegate?.quadrantViewWillBeginDragging(self)
    }
    
    func todoTaskListView(_ listView: TodoTaskListView, willBeginEditingTask task: TodoTask) {
        delegate?.quadrantView(self, willBeginEditingTask: task)
    }
}


class RequestManager {
    
    private(set) var currentRequestID: UUID?
    
    @discardableResult
    func executeRequest() -> UUID {
        let requestID = UUID()
        currentRequestID = requestID
        return requestID
    }
    
    func shouldProceed(with requestID: UUID) -> Bool {
        return requestID == currentRequestID
    }
}
