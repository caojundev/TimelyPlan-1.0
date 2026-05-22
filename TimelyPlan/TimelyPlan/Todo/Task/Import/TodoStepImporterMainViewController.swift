//
//  TodoStepImporterMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/22.
//

import Foundation
import UIKit

class TodoStepImporterMainViewController: TPTableSectionsViewController {
    
    var inputText = """
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
        cellItem.placeholder = resGetString("Import Steps")
        cellItem.isNewlineEnabled = true
        cellItem.textColor = resGetColor(.title)
        cellItem.font = .boldSystemFont(ofSize: 14.0)
        cellItem.returnKeyType = .next
        cellItem.maxCount = .max
        cellItem.updater = {
            self?.inputCellItem.text = self?.inputText
        }
        
        cellItem.editingChanged = { textView in
            self?.inputText = textView.text
        }
        
        cellItem.didEndEditing = { textView in
            let text = textView.text?.whitespacesAndNewlinesTrimmedString
            if let text = text, text.count > 0 {
                self?.inputText = text
            }
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
        self.title = resGetString("Import Steps")
        self.navigationItem.leftBarButtonItem = self.chevronDownCancelButtonItem
        self.wrapperView.isKeyboardAdjusterEnabled = true /// 键盘自动调整开启
        self.tableView.keyboardDismissMode = .interactive
        self.setupActionsBar(actions: [nextAction])
        self.sectionControllers = [inputSectionController]
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.reloadData()
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
    
    private func clickNext() {
        let importer = TodoStepImporter()
        let steps = importer.importSteps(from: self.inputText)
        let previewVC = TodoStepImporterPreviewViewController(steps: steps)
        navigationController?.pushViewController(previewVC, animated: true)
    
        print(importer.visualize(steps))
    }
    
}
