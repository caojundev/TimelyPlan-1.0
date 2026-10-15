//
//  WSCountdownPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation
import UIKit

/// 倒数日单元格。注册于倒数日组件提供者，由工作台按组件类型取用。
class WSCountdownPluginCell: WorkspacePluginCell {

    override var pluginBackgroundColor: UIColor {
        return .random
    }
    
}
