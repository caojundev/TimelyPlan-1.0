//
//  TaskPickerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/19.
//

import Foundation
import UIKit

class TaskPickerViewController: TPViewController {
    
    /// 选中任务回调
    var didSelectTask: ((TaskRepresentable?) -> Void)?
    
    /// 当前选中任务
    private(set) var task: TaskRepresentable?
    
    /// 清除按钮
    private lazy var clearButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: resGetImage("clear_24"),
                                   style: .done,
                                   target: self,
                                   action: #selector(clickClear(_:)))
        item.tintColor = .danger6
        return item
    }()
    

    init(task: TaskRepresentable? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.task = task
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        if task != nil {
            navigationItem.rightBarButtonItem = clearButtonItem
        }
    }

    // MARK: - Event Response
    @objc private func clickClear(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithMediumStyle()
        dismiss(animated: true, completion: nil)
        didSelectTask?(nil)
    }
    
    // MARK: - Class Methods
    class func show(with task: TaskRepresentable?, animated: Bool, completion: ((TaskRepresentable?) -> Void)?) {
        let vc = TaskPickerViewController(task: task)
        vc.didSelectTask = { selectedTask in
            if selectedTask === task {
                return
            }
            
            completion?(selectedTask)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .formSheet
        navController.show(animated: animated)
    }
}
