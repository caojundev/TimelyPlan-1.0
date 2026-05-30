//
//  TodoImportInputViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/30.
//

import Foundation
import UIKit

class TodoImportInputViewController: TPViewController, UITextViewDelegate {
    
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
    
    var placeholder: String? {
        get {
            return textView.placeholder
        }
        
        set {
            textView.placeholder = newValue
        }
    }
    
    /// 步骤最大深度
    var maxDepth: Int {
        return kTodoStepMaxDepth
    }
    
    lazy var textView: TPTextView = {
        let textView = TPTextView()
        textView.delegate = self
        textView.showsVerticalScrollIndicator = true
        textView.showsHorizontalScrollIndicator = false
        textView.backgroundColor = .secondarySystemGroupedBackground
        textView.textContainerInset = UIEdgeInsets(horizontal: 16.0, vertical: 16.0)
        textView.inputAccessoryView = textView.dismissToolbar
        textView.textColor = resGetColor(.title)
        textView.font = .systemFont(ofSize: 14.0)
        textView.placeholderMargin = 6.0
        textView.returnKeyType = .next
        return textView
    }()
    
    lazy var previewAction: TPButtonAction = {
        let action = TPButtonAction(title:  resGetString("Preview")) {  [weak self] action in
            self?.clickPreview()
        }
        
        return action
    }()
    
    private lazy var keyboardAdjuster: TPKeyboardAdjuster = {
        let adjuster = TPKeyboardAdjuster(scrollView: textView)
        adjuster.adjustsForExternalResponder = true
        return adjuster
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        view.addSubview(textView)
        setupActionsBar(actions: [previewAction])
        keyboardAdjuster.isEnabled = true
        textView.text = inputText
        updatePreviewButton()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let margins = UIEdgeInsets(top: 4.0, left: 12.0, bottom: actionsBarHeight + 12.0, right: 12.0)
        textView.frame = view.safeAreaFrame().inset(by: margins)
        textView.layer.cornerRadius = 16.0
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func handleFirstAppearance() {
        textView.becomeFirstResponder()
    }
    
    private func updatePreviewButton() {
        let text = textView.text.whitespacesAndNewlinesTrimmedString
        previewAction.isEnabled = text.count > 0
    }
    
    
    func clickPreview() {
        let inputText = textView.text.whitespacesAndNewlinesTrimmedString
        guard inputText.count > 0 else {
            return
        }

        let importer = TodoStepImporter()
        importer.maxDepth = maxDepth
        let steps = importer.importSteps(from: inputText)
        guard steps.count > 0 else {
            return
        }
        
        previewSteps(steps)
    }

    func previewSteps(_ steps: [TodoStep]) {
        
    }

    // MARK: -
    func textViewDidChange(_ textView: UITextView) {
        updatePreviewButton()
    }
}
