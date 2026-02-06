//
//  QuadrantMatrixView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/22.
//

import Foundation
import UIKit

protocol QuadrantMatrixViewDelegate: AnyObject {
    
    func quadrantMatrixView(_ view: QuadrantMatrixView, fetcherForQuadrant quadrant: Quadrant) -> QuadrantFetcher
    
    func quadrantMatrixView(_ view: QuadrantMatrixView, didClickAddForQuadrant quadrant: Quadrant)
    
    func quadrantMatrixView(_ view: QuadrantMatrixView, didClickTapTitleForQuadrant quadrant: Quadrant)
    
}

class QuadrantMatrixView: UIView {
    
    weak var delegate: QuadrantMatrixViewDelegate?
    
    /// 象限视图数组
    private var quadrantViews: [QuadrantView] = []
    
    /// 象限之间的间隔
    private var spacing: CGFloat = 5.0
    
    /// 外边界间距
    private var margins: UIEdgeInsets = UIEdgeInsets(value: 5.0)
    
    /// 任务管理器
    private var taskController = TodoTaskController()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupQuadrantViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutQuadrantViews()
    }
    
    override func endEditing(_ force: Bool) -> Bool {
        endEditingQuadrantViews()
        return true
    }
    
    /// 初始化象限视图
    private func setupQuadrantViews() {
        var views = [QuadrantView]()
        let showDetail = QuadrantSettingAgent.shared.showDetail
        let layout = QuadrantSettingAgent.shared.layout
        let quadrants = layout.getQuadrants()
        let titlePosition = layout.getTitlePosition()
        for quadrant in quadrants {
            let view = QuadrantView(quadrant: quadrant, showDetail: showDetail)
            view.titlePosition = titlePosition
            view.delegate = self
            views.append(view)
            addSubview(view)
        }
        
        self.quadrantViews = views
    }
    
    /// 布局象限视图
    private func layoutQuadrantViews() {
        let layoutFrame = safeLayoutFrame().inset(by: margins)
        let width = (layoutFrame.width - spacing) / 2.0
        let height = (layoutFrame.height - spacing) / 2.0
        for (index, quadrantView) in quadrantViews.enumerated() {
            let row = index / 2
            let col = index % 2
            let x = layoutFrame.minX + CGFloat(col) * (width + spacing)
            let y = layoutFrame.minY + CGFloat(row) * (height + spacing)
            quadrantView.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
    // MARK: - Public Methods
    
    /// 异步执行更新操作
    func asyncReloadData() {
        for quadrantView in quadrantViews {
            quadrantView.asyncReloadData()
        }
    }

    func asyncPerformUpdate(completion: ((QuadrantView) -> Void)? = nil) {
        for quadrantView in quadrantViews {
            quadrantView.asyncPerformUpdate { isSuccess in
                if isSuccess {
                    completion?(quadrantView)
                }
            }
        }
    }
    
    func didUpdate(with infos: [TodoTaskChangeInfo]) {
        for quadrantView in quadrantViews {
            quadrantView.didUpdate(with: infos)
        }
    }
    
    func didDeleteTasks(_ tasks: [TodoTask]) {
        for quadrantView in quadrantViews {
            quadrantView.didDeleteTasks(tasks)
        }
    }
    
    func reloadCell(for task: TodoTask) {
        for quadrantView in quadrantViews {
            quadrantView.reloadCell(for: task)
        }
    }
    
    func updateQuadrantShowDetail() {
        let showDetail = QuadrantSettingAgent.shared.showDetail
        for quadrantView in quadrantViews {
            quadrantView.setShowDetail(showDetail)
        }
    }
    
    func updateLayout(animated: Bool = true) {
        updateQuadrantTitlePosition()
        updateQuadrantViewOrders(animated: animated)
    }
    
    private func updateQuadrantViewOrders(animated: Bool = false) {
        let layout = QuadrantSettingAgent.shared.layout
        let quadrants = layout.getQuadrants()
        self.quadrantViews = quadrantViews.sorted(by: { lView, rView in
            let lIndex = quadrants.firstIndex(of: lView.quadrant) ?? 0
            let rIndex = quadrants.firstIndex(of: rView.quadrant) ?? 0
            return lIndex < rIndex
        })
        
        if animated {
            animateLayout(withDuration: 0.4)
        } else {
            setNeedsLayout()
        }
    }

    private func updateQuadrantTitlePosition() {
        let layout = QuadrantSettingAgent.shared.layout
        let titlePosition = layout.getTitlePosition()
        for quadrantView in quadrantViews {
            quadrantView.titlePosition = titlePosition
        }
    }
    
    // MARK: -
    
    func quadrantView(at point: CGPoint) -> QuadrantView? {
        for quadrantView in quadrantViews {
            if quadrantView.frame.contains(point) {
                return quadrantView
            }
        }
        
        return nil
    }
    
    func quadrantView(for quadrant: Quadrant) -> QuadrantView? {
        let result = quadrantViews.first { view in
            return view.quadrant == quadrant
        }
        
        return result
    }
    
    func indexPathForItem(at point: CGPoint) -> QuadrantIndexPath? {
        guard let quadrantView = quadrantView(at: point) else {
            return nil
        }
        
        let convertedPoint = self.convert(point, toViewOrWindow: quadrantView)
        guard let indexPath = quadrantView.indexPathForItem(at: convertedPoint) else {
            return nil
        }
    
        return QuadrantIndexPath(quadrant: quadrantView.quadrant, indexPath: indexPath)
    }
    
    func cellForItem(at indexPath: QuadrantIndexPath) -> UITableViewCell? {
        guard let quadrantView = quadrantView(for: indexPath.quadrant) else {
            return nil
        }
        
        return quadrantView.cellForItem(at: indexPath.indexPath)
    }
    
    func task(at indexPath: QuadrantIndexPath) -> TodoTask? {
        guard let quadrantView = quadrantView(for: indexPath.quadrant) else {
            return nil
        }
        
        return quadrantView.task(at: indexPath.indexPath)
    }
}

extension QuadrantMatrixView: QuadrantViewDelegate {
    
    // MARK: - QuadrantViewDelegate

    func fetcherForQuadrantView(_ view: QuadrantView) -> QuadrantFetcher? {
        return delegate?.quadrantMatrixView(self, fetcherForQuadrant: view.quadrant)
    }

    func quadrantView(_ view: QuadrantView, didSelectTask task: TodoTask) {
        taskController.editTask(task)
    }
    
    func quadrantView(_ view: QuadrantView, didClickCheckboxForTask task: TodoTask) {
        taskController.clickCheckbox(for: task)
    }
    
    func quadrantView(_ view: QuadrantView, leadingSwipeActionsConfigurationForTask task: TodoTask) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    func quadrantView(_ view: QuadrantView, trailingSwipeActionsConfigurationForTask task: TodoTask) -> UISwipeActionsConfiguration? {
        let trashAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            self.taskController.moveToTrash(with: task)
            completion(true)
        }
        
        trashAction.image = resGetImage("todo_task_action_trash_24")?.withTintColor(.white)
        return UISwipeActionsConfiguration(actions: [trashAction])
    }
  
    func quadrantViewDidClickAdd(_ view: QuadrantView) {
        delegate?.quadrantMatrixView(self, didClickAddForQuadrant: view.quadrant)
    }
    
    func quadrantViewDidTapTitleView(_ view: QuadrantView) {
        delegate?.quadrantMatrixView(self, didClickTapTitleForQuadrant: view.quadrant)
    }
    
    func quadrantViewWillBeginDragging(_ view: QuadrantView) {
        endEditingQuadrantViews()
    }
    
    func quadrantView(_ view: QuadrantView, willBeginEditingTask task: TodoTask) {
        endEditingQuadrantViews(except: view)
    }
    
    private func endEditingQuadrantViews(except view: QuadrantView? = nil) {
        for quadrantView in quadrantViews {
            if quadrantView != view {
                let _ = quadrantView.endEditing(true)
            }
        }
    }
}
