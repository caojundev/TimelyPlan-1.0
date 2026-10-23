//
//  WSCountdownMediumEventsGridPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

/// 倒数日·中·事项（网格）的单元格。
///
/// 两列两行的简略事项卡片，展示四个倒数日事项。
class WSCountdownMediumEventsGridPluginCell: WSPluginCell {
    
    override func makePluginContentView() -> WSPluginContentView! {
        return WSCountdownEventsCardContentView(itemCount: WSCountdownEventsItemCount.mediumGrid,
                                                columnCount: 2)
    }
    
}
