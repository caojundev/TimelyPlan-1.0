//
//  WSQuadrantSmallCountsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 四象限·小·数量的内容视图。以两列两行的网格展示各象限的未完成任务数。
class WSQuadrantSmallCountsContentView: WSQuadrantCountsContentView {
    
    init() {
        super.init(rowCount: 2, columnCount: 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return WSQuadrantSmallCountsRowView()
    }
}
