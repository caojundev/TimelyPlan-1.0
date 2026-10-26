//
//  WSHabitSmallSelectedConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

/// 习惯·小·自选的配置界面，用于选择要展示的习惯任务
class WSHabitSmallSelectedConfigViewController: WSPluginConfigViewController,
                                                TaskBindViewControllerDelegate {
    
    /// 当前配置
    private lazy var config: WSHabitSelectedConfiguration = {
        return configuration(as: WSHabitSelectedConfiguration.self)
            ?? WSHabitSelectedConfiguration()
    }()
    
    /// 已选中的任务特征值。用于列表展示选中勾选
    private lazy var selectedFeature: TaskFeature? = {
        guard let identifier = config.taskIdentifier,
              let task = HabitRepository.activeTasks().first(where: { $0.identifier == identifier }) else {
            return nil
        }
        
        return task.feature
    }()
    
    /// 习惯任务选择列表
    private lazy var bindViewController: HabitTaskBindViewController = {
        let viewController = HabitTaskBindViewController(selectedFeature: selectedFeature)
        viewController.delegate = self
        return viewController
    }()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Select Habit")
        contentViewController = bindViewController
    }
    
    // MARK: - 选择
    /// 保存用户选择的习惯任务
    private func selectTask(_ task: HabitTask) {
        var config = self.config
        config.taskIdentifier = task.identifier
        self.config = config
        updateConfiguration(config)
        
        if let presentingVC = presentingViewController {
            presentingVC.dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - TaskBindViewControllerDelegate
    func taskBindViewController(_ viewController: UIViewController, didSelectTask task: TaskRepresentable) {
        guard let task = task as? HabitTask else {
            return
        }
        
        selectTask(task)
    }
}
