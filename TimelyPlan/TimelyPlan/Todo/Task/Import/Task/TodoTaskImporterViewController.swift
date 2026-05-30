//
//  TodoTaskImporterViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/30.
//

import Foundation

class TodoTaskImporterViewController: TodoImportInputViewController {
    
    override var maxDepth: Int {
        return kTodoStepMaxDepth + 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Import Tasks")
        placeholder = resGetString("Enter tasks, one per line\nUse - [ ] or - [x] for status\nIndent with spaces for steps")
    }
    
    override func previewSteps(_ steps: [TodoStep]) {
        let previewVC = TodoTaskImporterPreviewViewController(steps: steps)
        previewVC.completion = completion
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.pushViewController(previewVC, animated: true)
    }
}
