//
//  WSTodoTaskSelectionState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 选择状态

/// 自选任务的选择状态。
///
/// 任务列表与搜索结果共用同一份状态，保证选择顺序与数量上限规则一致。
class WSTodoTaskSelectionState {

    /// 已选任务标识，保持选择顺序
    private(set) var identifiers: [String]

    /// 最多可选择的任务数量
    let maximumSelectionCount: Int

    init(identifiers: [String], maximumSelectionCount: Int) {
        self.identifiers = identifiers
        self.maximumSelectionCount = max(maximumSelectionCount, 1)
    }

    func contains(_ identifier: String) -> Bool {
        return identifiers.contains(identifier)
    }

    /// 切换选中状态。超出上限时忽略本次选择并返回 false
    @discardableResult
    func toggle(_ identifier: String) -> Bool {
        if let index = identifiers.firstIndex(of: identifier) {
            identifiers.remove(at: index)
            TPImpactFeedback.impactWithSoftStyle()
            return true
        }

        guard identifiers.count < maximumSelectionCount else {
            TPImpactFeedback.impactWithRigidStyle()
            return false
        }

        identifiers.append(identifier)
        TPImpactFeedback.impactWithSoftStyle()
        return true
    }

    /// 同步外部变化，保持选择顺序
    func update(_ identifiers: [String]) {
        self.identifiers = identifiers
    }
}
