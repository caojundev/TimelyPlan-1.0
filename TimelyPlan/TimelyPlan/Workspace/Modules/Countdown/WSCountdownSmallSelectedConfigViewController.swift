//
//  WSCountdownSmallSelectedConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/19.
//

import Foundation
import UIKit

/// 倒数日·小·自选的配置界面，用于选择要展示的倒数日事件。
///
/// 事项选择复用任务绑定中的 `CountdownEventBindViewController`：
/// 列表样式、选中勾选、数据变更刷新与占位视图都与「绑定倒数日」保持一致。
class WSCountdownSmallSelectedConfigViewController: WSPluginConfigViewController,
                                                  TaskBindViewControllerDelegate {
    
    /// 当前配置
    private lazy var config: WSCountdownSelectedConfiguration = {
        return configuration(as: WSCountdownSelectedConfiguration.self)
            ?? WSCountdownSelectedConfiguration()
    }()
    
    /// 已选中的事项特征值。用于列表展示选中勾选
    private var selectedFeature: TaskFeature? {
        guard let eventIdentifier = config.eventIdentifier else {
            return nil
        }
        
        return TaskFeature(type: .countdown,
                           identifier: eventIdentifier,
                           snapshotName: nil)
    }
    
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
    
    // MARK: - TaskBindViewControllerDelegate
    func taskBindViewController(_ viewController: UIViewController, didSelectTask task: TaskRepresentable) {
        guard let event = task as? CountdownEvent else {
            return
        }
        
        var config = self.config
        config.eventIdentifier = event.identifier
        self.config = config
        
        updateConfiguration(config)
        dismiss(animated: true)
    }
}
