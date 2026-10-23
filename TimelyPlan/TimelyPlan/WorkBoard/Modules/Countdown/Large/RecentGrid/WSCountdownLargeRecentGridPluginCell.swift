//
//  WSCountdownLargeRecentGridPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

/// 倒数日·大·最近（网格）的单元格。
///
/// 两列四行的简略事项卡片，展示最近的八个倒数日事项。
class WSCountdownLargeRecentGridPluginCell: WSPluginCell {
    
    override func makePluginContentView() -> WSPluginContentView! {
        return WSCountdownRecentCardContentView(itemCount: WSCountdownRecentItemCount.largeGrid,
                                                columnCount: 2)
    }
    
}
