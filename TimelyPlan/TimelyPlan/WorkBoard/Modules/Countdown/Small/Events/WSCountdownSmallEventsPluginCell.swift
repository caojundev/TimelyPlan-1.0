//
//  WSCountdownSmallEventsPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

/// 倒数日·小·事项的单元格。
///
/// 两张纵向排列的简略事项卡片，展示最近或用户自选的两个倒数日事项。
class WSCountdownSmallEventsPluginCell: WSPluginCell {
    
    override func makePluginContentView() -> WSPluginContentView! {
        return WSCountdownEventsCardContentView(itemCount: WSCountdownEventsItemCount.small,
                                                columnCount: 1)
    }
    
}
