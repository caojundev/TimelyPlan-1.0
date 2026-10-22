//
//  WSCountdownSmallRecentPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

/// 倒数日·小·最近的单元格。
///
/// 内容视图使用简略事项卡片，展示最近的两个倒数日事项。
class WSCountdownSmallRecentPluginCell: WSPluginCell {
    
    override func makePluginContentView() -> WSPluginContentView! {
        return WSCountdownSmallRecentContentView()
    }
    
}
