//
//  WSCountdownSmallSelectedConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/19.
//

import Foundation
import UIKit

/// 倒数日·小·自选的配置界面，用于选择要展示的倒数日事件
class WSCountdownSmallSelectedConfigViewController: WSPluginConfigViewController,
                                                  TaskBindViewControllerDelegate {
    
    /// 当前配置
    private lazy var config: WSCountdownSelectedConfiguration = {
        return configuration(as: WSCountdownSelectedConfiguration.self)
            ?? WSCountdownSelectedConfiguration()
    }()
    
    /// 已选中的事项特征值。用于列表展示选中勾选
    private lazy var selectedFeature: TaskFeature? = {
        guard let eventIdentifier = config.eventIdentifier,
              let event = CountdownRepository.getEvent(withIdentifier: eventIdentifier) else {
            return nil
        }
        
        return event.feature
    }()
    
    /// 倒数日事项选择列表
    private lazy var bindViewController: CountdownEventBindViewController = {
        let viewController = CountdownEventBindViewController(selectedFeature: selectedFeature)
        viewController.delegate = self
        return viewController
    }()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Select Countdown")
        contentViewController = bindViewController
    }
    
    // MARK: - 选择
    /// 保存用户选择的倒数日事项
    private func selectEvent(_ event: CountdownEvent) {
        var config = self.config
        config.eventIdentifier = event.identifier
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
        guard let event = task as? CountdownEvent else {
            return
        }
        
        selectEvent(event)
    }
}
