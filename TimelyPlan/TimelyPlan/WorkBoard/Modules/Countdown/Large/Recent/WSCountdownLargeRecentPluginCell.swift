//
//  WSCountdownLargeRecentPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

/// 倒数日·大·最近的单元格。
///
/// 内容视图与中号·最近一致，仅在展示条数上不同：大号展示五个事项。
class WSCountdownLargeRecentPluginCell: WSPluginCell {
    
    override func makePluginContentView() -> WSPluginContentView! {
        return WSCountdownRecentContentView(itemCount: WSCountdownRecentItemCount.large)
    }
    
}
