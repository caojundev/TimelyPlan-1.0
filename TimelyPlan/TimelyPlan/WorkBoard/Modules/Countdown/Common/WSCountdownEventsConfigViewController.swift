//
//  WSCountdownEventsConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/23.
//

import Foundation
import UIKit

/// 倒数日「事项」类组件的配置界面。
///
/// 当前仅提供统一外壳，数据来源切换与自选事项的多选列表待后续实现。
class WSCountdownEventsConfigViewController: WSPluginConfigViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Countdown Options")
    }
}
