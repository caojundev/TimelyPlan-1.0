//
//  WSCountdownSmallRecentContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 倒数日·小·最近内容视图。
///
/// 两张简略事项卡片纵向排列，卡片样式与排列规则复用 `WSCountdownRecentCardContentView`。
class WSCountdownSmallRecentContentView: WSCountdownRecentCardContentView {
    
    init() {
        super.init(itemCount: WSCountdownRecentItemCount.small, columnCount: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
