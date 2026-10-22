//
//  WSCountdownMediumRecentGridContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 倒数日·中·最近（网格）内容视图。
///
/// 四张简略事项卡片按两列两行排列，卡片样式与排列规则复用 `WSCountdownRecentCardContentView`。
class WSCountdownMediumRecentGridContentView: WSCountdownRecentCardContentView {
    
    init() {
        super.init(itemCount: WSCountdownRecentItemCount.mediumGrid, columnCount: 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
