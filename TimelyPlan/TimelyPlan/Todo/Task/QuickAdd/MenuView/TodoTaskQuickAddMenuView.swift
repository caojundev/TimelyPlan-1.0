//
//  TodoTaskQuickAddMenuView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/23.
//

import Foundation
import UIKit

protocol TodoTaskQuickAddMenuViewDelegate: AnyObject {
    
    func quickAddMenuView(_ menuView: TodoTaskQuickAddMenuView,
                          didChangeTask newTask: TodoQuickAddTask,
                          with actionType: TodoTaskQuickAddMenuActionType)
}

class TodoTaskQuickAddMenuView: UIView,
                                TPCollectionSectionControllersList {
    
    weak var delegate: TodoTaskQuickAddMenuViewDelegate?

    var task: TodoQuickAddTask {
        get {
            return sectionController.task
        }
        
        set {
            sectionController.task = newValue
        }
    }
    
    var sectionControllers: [TPCollectionBaseSectionController]?

    /// 集合视图适配器
    private let adapter: TPCollectionViewAdapter = TPCollectionViewAdapter()
    
    /// 集合视图
    private lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        
       let collectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionViewLayout)
        collectionView.isPrefetchingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private lazy var sectionController: TodoTaskQuickAddMenuSectionController = {
        let sectionController = TodoTaskQuickAddMenuSectionController()
        sectionController.didChangeTask = { [weak self] task, actionType in
            self?.didChangeTask(task, with: actionType)
        }
        
        return sectionController
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        self.sectionControllers = [sectionController]
        self.adapter.collectionView = collectionView
        self.adapter.sectionInset = .zero
        self.adapter.dataSource = self
        self.adapter.delegate = self
        self.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.frame = bounds
        CATransaction.commit()
    }

    func reloadData() {
        adapter.reloadData()
    }
    
    private func didChangeTask(_ newTask: TodoQuickAddTask, with actionType: TodoTaskQuickAddMenuActionType) {
        delegate?.quickAddMenuView(self,
                                   didChangeTask: newTask,
                                   with: actionType)
    }
}
