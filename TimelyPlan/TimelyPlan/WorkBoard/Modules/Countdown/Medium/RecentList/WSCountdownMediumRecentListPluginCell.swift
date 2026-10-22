//
//  WSCountdownMediumRecentListPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/21.
//

import Foundation
import UIKit

/// 倒数日·中·最近（列表）的单元格。
///
/// 内容视图与大号·最近一致，仅在展示条数上不同：中号列表展示三个事项。
class WSCountdownMediumRecentListPluginCell: WSPluginCell {
    
    override func makePluginContentView() -> WSPluginContentView! {
        return WSCountdownRecentContentView(itemCount: WSCountdownRecentItemCount.mediumList)
    }
    
}
