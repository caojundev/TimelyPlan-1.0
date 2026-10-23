//
//  WSCountdownMediumEventsListPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/21.
//

import Foundation
import UIKit

/// 倒数日·中·事项（列表）的单元格。
///
/// 逐行展示三个倒数日事项，视觉与倒数日列表单元格一致。
class WSCountdownMediumEventsListPluginCell: WSPluginCell {
    
    override func makePluginContentView() -> WSPluginContentView! {
        return WSCountdownEventsContentView(itemCount: WSCountdownEventsItemCount.mediumList)
    }
    
}
