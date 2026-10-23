//
//  WSCountdownLargeEventsGridPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

/// 倒数日·大·事项（网格）的单元格。
///
/// 两列四行的简略事项卡片，展示八个倒数日事项。
class WSCountdownLargeEventsGridPluginCell: WSPluginCell {
    
    override func makePluginContentView() -> WSPluginContentView! {
        return WSCountdownEventsCardContentView(itemCount: WSCountdownEventsItemCount.largeGrid,
                                                columnCount: 2)
    }
    
}
