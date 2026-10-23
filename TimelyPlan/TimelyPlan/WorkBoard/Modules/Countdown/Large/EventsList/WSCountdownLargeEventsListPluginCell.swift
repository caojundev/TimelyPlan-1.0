//
//  WSCountdownLargeEventsListPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

/// 倒数日·大·事项（列表）的单元格。
///
/// 逐行展示五个倒数日事项，视觉与倒数日列表单元格一致。
class WSCountdownLargeEventsListPluginCell: WSPluginCell {
    
    override func makePluginContentView() -> WSPluginContentView! {
        return WSCountdownEventsContentView(itemCount: WSCountdownEventsItemCount.largeList)
    }
    
}
