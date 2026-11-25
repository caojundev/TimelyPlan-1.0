//
//  WSQuadrantMediumCountsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 四象限·中·数量的内容视图。以一行四列横向展示各象限的未完成任务数。
class WSQuadrantMediumCountsContentView: WSQuadrantCountsContentView {
    
    init() {
        super.init(rowCount: 1, columnCount: 4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return WSQuadrantMediumCountsRowView()
    }
}
