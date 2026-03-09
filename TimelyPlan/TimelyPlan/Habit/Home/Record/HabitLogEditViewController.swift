//
//  HabitLogEditViewController.swift
//  iTimeFlow
//
//  Created by caojun on 2023/8/22.
//

import UIKit

class HabitLogEditViewController: TPViewController, UITextViewDelegate {

    var completion: ((String?) -> Void)?
    
    /// 日期
    private(set) var date: Date = .now
    
    /// 日志
    private(set) var log: String?
    
    /// 文本视图
    private var textView: TPTextView = {
        let textView = TPTextView()
        textView.font = BOLD_BODY_FONT
        textView.layer.maskedCorners = [.layerMaxXMaxYCorner,
                                        .layerMaxXMinYCorner,
                                        .layerMinXMaxYCorner,
                                        .layerMinXMinYCorner]
        textView.layer.cornerRadius = 18.0
        textView.textContainerInset = UIEdgeInsets(value: 16.0)
        textView.placeholderPosition = .topLeft
        textView.placeholder = resGetString("Record your feelings or thoughts today...")
        textView.backgroundColor = UIColor(hex: 0x888888, alpha: 0.1)
        textView.textColor = .label
        return textView
    }()

    /// 清除按钮
    private lazy var clearButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: resGetString("Clear"),
                                   style: .done,
                                   target: self,
                                   action: #selector(clickClear(_:)))
        item.tintColor = .danger1
        return item
    }()

    init(log: String?, date: Date = .now) {
        super.init(nibName: nil, bundle: nil)
        self.log = log
        self.date = date
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = date.monthDayShortWeekdaySymbolString
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        if let log = log, log.count > 0 {
            /// 显示清除按钮
            self.navigationItem.rightBarButtonItem = clearButtonItem
        }
    
        self.preferredContentSize = CGSize(width: 420.0, height: 360.0)
        
        self.textView.text = log?.whitespacesAndNewlinesTrimmedString
        self.textView.delegate = self
        self.view.addSubview(self.textView)
        self.setupActionsBar(actions: [doneAction])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.layoutFrame()
        textView.width = layoutFrame.width - 20.0
        textView.height = actionsBar!.top - 20.0
        textView.left = layoutFrame.minX
        textView.top = 10.0
        textView.placeholderColor = .label.withAlphaComponent(0.4)
    }
    
    override func clickDone() {
        let log = textView.text.whitespacesAndNewlinesTrimmedString
        completion?(log.count > 0 ? log : nil)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Event Response
    @objc private func clickClear(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithMediumStyle()
        completion?(nil)
        dismiss(animated: true, completion: nil)
    }
    
}
