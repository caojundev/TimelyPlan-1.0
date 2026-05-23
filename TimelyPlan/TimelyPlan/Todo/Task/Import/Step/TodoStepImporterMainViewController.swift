//
//  TodoStepImporterMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/22.
//

import Foundation
import UIKit

class TodoStepImporterMainViewController: TPTableSectionsViewController {
    
    var inputText: String? = """
    完成项目报告
      - [x] 收集数据
        - [ ] 销售数据
        - [ ] 用户反馈
      - [ ] 编写分析
    准备会议
      - [ ] 制作PPT
      - [ ] 预定会议室
    买水果
    """
    
    var completion: (([TodoStep]) -> Void)?
    
    lazy var nextAction: TPButtonAction = {
        let action = TPButtonAction(title:  resGetString("Next")) {  [weak self] action in
            self?.clickNext()
        }
        
        return action
    }()
    
    lazy var inputCellItem: TPAutoResizeTextViewTableCellItem = {[weak self] in
        let cellItem = TPAutoResizeTextViewTableCellItem()
        cellItem.minimumHeight = 480.0
        cellItem.maximumHeight = 640.0
        cellItem.contentPadding = UIEdgeInsets(horizontal: 15.0, vertical: 10.0)
        cellItem.placeholder = resGetString("Enter steps, one per line\nUse - [ ] or - [x] for status\nIndent with spaces for sub-steps")
        cellItem.isNewlineEnabled = true
        cellItem.textColor = resGetColor(.title)
        cellItem.font = .systemFont(ofSize: 14.0)
        cellItem.returnKeyType = .next
        cellItem.maxCount = .max
        cellItem.updater = {
            self?.inputCellItem.text = self?.inputText
        }
        
        cellItem.editingChanged = { textView in
            self?.inputText = textView.text
            self?.updateNextButton()
        }
        
        cellItem.didEndEditing = { textView in
            let text = textView.text?.whitespacesAndNewlinesTrimmedString
            self?.inputText = text
            self?.updateNextButton()
        }
        
        return cellItem
    }()

    lazy var inputSectionController: TPTableItemSectionController = { [weak self] in
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 15.0
        sectionController.headerItem.title = nil
        sectionController.cellItems = [inputCellItem]
        return sectionController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Import Steps")
        navigationItem.leftBarButtonItem = self.chevronDownCancelButtonItem
        wrapperView.isKeyboardAdjusterEnabled = true /// 键盘自动调整开启
        tableView.keyboardDismissMode = .interactive
        setupActionsBar(actions: [nextAction])
        sectionControllers = [inputSectionController]
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        reloadData()
        updateNextButton()
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func handleFirstAppearance() {
        if let cell = adapter.cellForItem(inputCellItem) as? TPTextViewTableCell {
            cell.textView.becomeFirstResponder()
        }
    }
    
    private func updateNextButton() {
        guard let inputText = inputText, inputText.count > 0 else {
            nextAction.isEnabled = false
            return
        }
        
        nextAction.isEnabled = true
    }
    
    private func clickNext() {
        guard let inputText = inputText else {
            return
        }

        let importer = TodoStepImporter()
        let steps = importer.importSteps(from: inputText)
        guard steps.count > 0 else {
            return
        }
        
        let previewVC = TodoStepImporterPreviewViewController(steps: steps)
        previewVC.completion = completion
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.pushViewController(previewVC, animated: true)
    }
    
}
