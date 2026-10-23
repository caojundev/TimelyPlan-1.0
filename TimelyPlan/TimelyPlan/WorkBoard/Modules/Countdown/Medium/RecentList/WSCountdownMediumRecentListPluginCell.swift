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
/// 逐行展示最近三个倒数日事项，视觉与倒数日列表单元格一致。
class WSCountdownMediumRecentListPluginCell: WSPluginCell {
    
    override func makePluginContentView() -> WSPluginContentView! {
        return WSCountdownRecentContentView(itemCount: WSCountdownRecentItemCount.mediumList)
    }
    
}
