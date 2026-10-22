//
//  WSCountdownMediumRecentGridPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

/// 倒数日·中·最近（网格）的单元格。
///
/// 内容视图为两列两行的简略事项卡片，展示最近的四个倒数日事项。
class WSCountdownMediumRecentGridPluginCell: WSPluginCell {
    
    override func makePluginContentView() -> WSPluginContentView! {
        return WSCountdownMediumRecentGridContentView()
    }
    
}
