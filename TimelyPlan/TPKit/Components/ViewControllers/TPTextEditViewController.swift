//
//  TPTextEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/23.
//

import Foundation
import UIKit

class TPTextEditViewController: TPViewController, UITextViewDelegate {

    /// 编辑完成回调
    var didEndEditing: ((String?) -> Void)?
    
    /// 文本
    private(set) var text: String?
    
    /// 文本视图
    private var textView: TPTextView = {
        let textView = TPTextView()
        textView.font = BOLD_SYSTEM_FONT
        textView.layer.maskedCorners = [.layerMaxXMaxYCorner,
                                        .layerMaxXMinYCorner,
                                        .layerMinXMaxYCorner,
                                        .layerMinXMinYCorner]
        textView.layer.cornerRadius = 16.0
        textView.textContainerInset = UIEdgeInsets(value: 15.0)
        textView.showsVerticalScrollIndicator = false
        textView.backgroundColor = Color(light: 0xFAFAFA, dark: 0x23252E, alpha: 0.4)
        textView.textColor = resGetColor(.title)
        
        textView.placeholderPosition = .topLeft
        textView.placeholderColor = .label.withAlphaComponent(0.4)
        textView.placeholder = resGetString("Write down your thoughts")
        return textView
    }()

    /// 清除按钮
    private lazy var clearButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: resGetImage("clear_24"),
                                   style: .done,
                                   target: self,
                                   action: #selector(clickClear(_:)))
        item.tintColor = .danger6
        return item
    }()
    
    /// 动作栏顶部间距
    private let actionsBarTopMargin = 10.0

    init(text: String?) {
        super.init(nibName: nil, bundle: nil)
        self.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.padding = UIEdgeInsets(top: 5.0, left: 15.0, bottom: 5.0, right: 15.0)
        preferredContentSize = CGSize(width: 420.0, height: 360.0)
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        if let text = text, text.count > 0 {
            /// 显示清除按钮
            navigationItem.rightBarButtonItem = clearButtonItem
        }
        
        textView.text = text?.whitespacesAndNewlinesTrimmedString
        textView.delegate = self
        view.addSubview(textView)
        setupActionsBar(actions: [doneAction])
        actionsBar?.padding = UIEdgeInsets(vertical: 10.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.layoutFrame()
        textView.width = layoutFrame.width
        if let actionsBar = actionsBar {
            textView.height = actionsBar.top - actionsBarTopMargin
        } else {
            textView.height = layoutFrame.height
        }

        textView.origin = layoutFrame.origin
    }
    
    override var navigationBarTitleFont: UIFont? {
        return BOLD_SYSTEM_FONT
    }
    
    override func clickDone() {
        let text = textView.text.whitespacesAndNewlinesTrimmedString
        didEndEditing?(text.count > 0 ? text : nil)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Event Response
    @objc private func clickClear(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithMediumStyle()
        didEndEditing?(nil)
        dismiss(animated: true, completion: nil)
    }
    
}
