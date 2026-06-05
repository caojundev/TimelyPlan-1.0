//
//  TodoTaskImporterPreviewViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/30.
//

import Foundation
import UIKit

class TodoTaskImporterPreviewViewController: TodoStepImporterPreviewViewController {
    
    override func setupEditSectionController(steps: [TodoStep]) {
        self.editSectionController = TodoTaskImporterStepEditSectionController(steps: steps)
    }
    
    override func navigationTitle() -> String? {
        return resGetString("Tasks Preview")
    }
    
    override func footerTitle() -> String? {
        return resGetString("Tap to edit task or step")
    }
}

class TodoTaskImporterStepEditSectionController: TodoImporterStepEditSectionController {
    
    override func newCellItem(with step: TodoStep) -> TodoTaskStepEditCellItem {
        let cellItem = TodoImporterStepCellItem(step: step)
        cellItem.registerClass = TodoTaskImporterStepCell.self
        return cellItem
    }
}

class TodoTaskImporterStepCell: TodoImporterStepCell {

    override func layoutSubviews() {
        super.layoutSubviews()
        let level = depthLineLayer.indentationLevel
        if level == 0 {
            checkbox.cornerRadius = 8.0
        } else {
            checkbox.cornerRadius = .greatestFiniteMagnitude
        }
    }
}
