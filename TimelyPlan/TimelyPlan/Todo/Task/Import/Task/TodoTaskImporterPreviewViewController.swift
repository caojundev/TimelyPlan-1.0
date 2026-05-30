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
    
    override func updateTitle() {
        self.title = resGetString("Tasks Preview")
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
            checkbox.cornerRadius = 6.0
        } else {
            checkbox.cornerRadius = .greatestFiniteMagnitude
        }
    }
}
