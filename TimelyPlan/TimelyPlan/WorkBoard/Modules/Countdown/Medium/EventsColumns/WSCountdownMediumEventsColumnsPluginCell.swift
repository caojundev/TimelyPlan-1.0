//
//  WSCountdownMediumEventsColumnsPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/23.
//

import Foundation
import UIKit

/// 倒数日·中·事项（三列）的单元格。
///
/// 一行三列的竖排卡片，展示三个倒数日事项。
class WSCountdownMediumEventsColumnsPluginCell: WSPluginCell {
    
    override func makePluginContentView() -> WSPluginContentView! {
        return WSCountdownEventsCardContentView(itemCount: WSCountdownEventsItemCount.mediumColumns,
                                                columnCount: 3) {
            return WSCountdownColumnEventRowView()
        }
    }
    
}
