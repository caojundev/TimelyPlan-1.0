//
//  HabitManageActiveListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/6.
//

import Foundation
import UIKit

class HabitManageActiveListViewController: HabitManageBaseListViewController {
    
    /// 添加按钮
    private let addViewSize = CGSize(width: 40.0, height: 40.0)
    private let addViewMargin = 15.0
    private lazy var addView: TPAddView = {
        let view = TPAddView()
        view.didClickAdd = { [weak self] button in
            self?.didClickAdd(button)
        }
        
        return view
    }()
    
    private var reorder: TPCollectionDragInsertReorder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupReorder()
    }
    
    func setupReorder() {
        let reorder = TPCollectionDragInsertReorder(collectionView: listView.collectionView)
        reorder.isEnabled = true
        reorder.delegate = self
        self.reorder = reorder
    }
    
    override func setupSubviews() {
        self.view.addSubview(self.addView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeLayoutFrame()
        addView.size = addViewSize
        addView.bottom = layoutFrame.maxY - addViewMargin
        addView.right = layoutFrame.maxX - addViewMargin
        
        let insetBottom = view.height - addView.top - addViewMargin
        listView.contentInset = UIEdgeInsets(bottom: insetBottom)
    }
    
    // MARK: - Event Response
    @objc func didClickAdd(_ button: UIButton){
        taskController.createNewTask()
    }
}

extension HabitManageActiveListViewController: TPCollectionDragInsertReorderDelegate {
    
    // MARK: - TPCollectionDragInsertReorderDelegate
    func collectionDragReorder(_ reorder: TPCollectionDragReorder, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                canInsertItemTo targetIndexPath: IndexPath,
                                     from sourceIndexPath: IndexPath) -> Bool {
        return true
    }

    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder,
                                     inserItemTo targetIndexPath: IndexPath,
                                     from sourceIndexPath: IndexPath,
                                     depth: Int) -> IndexPath? {
        guard let tasks = listView.items(for: sourceIndexPath.section) as? [HabitTask] else {
            return nil
        }
        
        habit.reorderTask(in: tasks, fromIndex: sourceIndexPath.item, toIndex: targetIndexPath.item)
        listView.moveItem(at: sourceIndexPath, to: targetIndexPath)
        return targetIndexPath
    }
    
}
