//
//  TodoStepImporterMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/22.
//

import Foundation
import UIKit

class TodoStepImporterViewController: TodoImportInputViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Import Steps")
        placeholder = resGetString("Enter steps, one per line\nUse - [ ] or - [x] for status\nIndent with spaces for sub-steps")
    }
    
    override func previewSteps(_ steps: [TodoStep]) {
        let previewVC = TodoStepImporterPreviewViewController(steps: steps)
        previewVC.completion = completion
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.pushViewController(previewVC, animated: true)
    }
}
