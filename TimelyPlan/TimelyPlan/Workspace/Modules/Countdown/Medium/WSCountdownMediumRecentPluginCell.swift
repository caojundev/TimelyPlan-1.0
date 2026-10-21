//
//  WSCountdownMediumRecentPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/21.
//

import Foundation
import UIKit

/// 倒数日·中·最近的单元格。
class WSCountdownMediumRecentPluginCell: WSPluginCell {
    
    override func makePluginContentView() -> WSPluginContentView! {
        return WSCountdownMediumRecentContentView()
    }
    
}
