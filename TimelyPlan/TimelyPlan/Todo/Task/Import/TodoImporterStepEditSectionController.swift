//
//  TodoImporterStepEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/30.
//

import Foundation

class TodoImporterStepEditSectionController: TodoStepEditSectionController {
    
    override func newCellItem(with step: TodoStep) -> TodoTaskStepEditCellItem {
        return TodoImporterStepCellItem(step: step)
    }
}

class TodoImporterStepCellItem: TodoTaskStepEditCellItem {
    
    override init(step: TodoStep) {
        super.init(step: step)
        self.registerClass = TodoImporterStepCell.self
        self.rightViewSize = .zero
        self.rightViewMargins = UIEdgeInsets(right: 10.0)
    }
}

class TodoImporterStepCell: TodoTaskStepEditCell {

    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.rightView = nil
    }
}
