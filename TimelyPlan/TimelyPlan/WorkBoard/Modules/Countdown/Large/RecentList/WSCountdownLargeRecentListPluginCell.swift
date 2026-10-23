//
//  WSCountdownLargeRecentListPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

/// 倒数日·大·最近（列表）的单元格。
///
/// 逐行展示最近五个倒数日事项，视觉与倒数日列表单元格一致。
class WSCountdownLargeRecentListPluginCell: WSPluginCell {
    
    override func makePluginContentView() -> WSPluginContentView! {
        return WSCountdownRecentContentView(itemCount: WSCountdownRecentItemCount.largeList)
    }
    
}
