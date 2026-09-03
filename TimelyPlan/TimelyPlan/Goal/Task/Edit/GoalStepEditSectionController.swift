//
//  GoalStepEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/3.
//

import Foundation

class GoalStepEditSectionController: TodoStepEditSectionController {
    
    override func newCellItem(with step: TodoStep) -> TodoTaskStepEditCellItem {
        return GoalStepCellItem(step: step)
    }
}

class GoalStepCellItem: TodoTaskStepEditCellItem {
    
    override init(step: TodoStep) {
        super.init(step: step)
        self.registerClass = GoalStepCell.self
        self.rightViewSize = .zero
        self.rightViewMargins = UIEdgeInsets(right: 10.0)
    }
}

class GoalStepCell: TodoTaskStepEditCell {

    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.rightView = nil
    }
}
