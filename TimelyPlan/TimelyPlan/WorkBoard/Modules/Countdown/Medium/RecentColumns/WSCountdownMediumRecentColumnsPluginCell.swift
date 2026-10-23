//
//  WSCountdownMediumRecentColumnsPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/23.
//

import Foundation
import UIKit

/// 倒数日·中·最近（三列）的单元格。
///
/// 一行三列的竖排卡片，展示最近的三个倒数日事项。
class WSCountdownMediumRecentColumnsPluginCell: WSPluginCell {
    
    override func makePluginContentView() -> WSPluginContentView! {
        return WSCountdownRecentCardContentView(itemCount: WSCountdownRecentItemCount.mediumColumns,
                                                columnCount: 3) {
            return WSCountdownColumnEventRowView()
        }
    }
    
}
