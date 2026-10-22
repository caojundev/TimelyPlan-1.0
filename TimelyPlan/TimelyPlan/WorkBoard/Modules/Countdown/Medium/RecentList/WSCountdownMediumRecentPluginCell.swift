//
//  WSCountdownMediumRecentPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/21.
//

import Foundation
import UIKit

/// 倒数日·中·最近的单元格。
///
/// 内容视图与大号·最近一致，仅在展示条数上不同：中号展示三个事项。
class WSCountdownMediumRecentPluginCell: WSPluginCell {
    
    override func makePluginContentView() -> WSPluginContentView! {
        return WSCountdownRecentContentView(itemCount: WSCountdownRecentItemCount.medium)
    }
    
}
