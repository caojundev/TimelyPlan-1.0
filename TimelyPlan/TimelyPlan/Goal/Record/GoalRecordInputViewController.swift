//
//  GoalRecordInputViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/7.
//

import Foundation
import UIKit

/// 目标任务记录输入弹窗的编辑类型
enum GoalRecordInputMode {
    
    /// 添加记录
    case add
    
    /// 编辑既有记录
    case edit
}

/// 目标任务记录输入弹窗
class GoalRecordInputViewController: TPAlertController {

    /// 记录输入视图
    lazy var recordInputView: GoalRecordInputView = {
        let view = GoalRecordInputView(inputTypes: self.inputTypes)
        view.backgroundColor = .clear
        view.inputTypeDidChange = { [weak self] in
            self?.updateDoneActionEnabled()
        }
        view.textField.addTarget(self,
                                 action: #selector(textFieldEditingChanged(_:)),
                                 for: .editingChanged)
        view.remarkEditingChanged = { [weak self] in
            self?.updateDoneActionEnabled()
        }

        return view
    }()

    /// 可用记录输入类型
    let inputTypes: [GoalRecordInputType]

    /// 编辑类型（添加 / 编辑）
    let mode: GoalRecordInputMode

    /// 完成回调（输入数值、记录类型、备注）
    var completion: ((Int64, GoalRecordInputType, String?) -> Void)?

    /// 记录输入类型
    var inputType: GoalRecordInputType {
        get {
            return recordInputView.inputType
        }

        set {
            recordInputView.inputType = newValue
        }
    }

    /// 根据目标任务创建记录输入控制器
    static func inputViewController(for task: GoalTask) -> GoalRecordInputViewController {
        let inputTypes = GoalRecordInputType.allCases
        let inputType: GoalRecordInputType
        if task.checkType == .decrease {
            inputType = task.calculation == .update ? .update : .decrease
        } else {
            inputType = task.calculation == .update ? .update : .increase
        }

        let vc = GoalRecordInputViewController(inputTypes: inputTypes)
        vc.inputType = inputType
        return vc
    }
    
    /// 创建编辑用输入控制器（仅 增加/减少，标题为 Edit Record，预填原数值与备注）
    static func editingViewController(amount: Int64, note: String?) -> GoalRecordInputViewController {
        let vc = GoalRecordInputViewController(inputTypes: [.increase, .decrease], mode: .edit)
        vc.configureForEditing(amount: amount, note: note)
        return vc
    }
    
    /// 配置为编辑既有记录：预填数值与备注，并按原值正负确定默认类型
    func configureForEditing(amount: Int64, note: String?) {
        inputType = amount >= 0 ? .increase : .decrease
        recordInputView.textField.text = "\(abs(amount))"
        recordInputView.setRemark(note)
        updateDoneActionEnabled()
    }

    init(inputTypes: [GoalRecordInputType],
         mode: GoalRecordInputMode = .add) {
        self.inputTypes = inputTypes
        self.mode = mode
        let title: String
        switch mode {
        case .add:
            title = resGetString("Add Record")
        case .edit:
            title = resGetString("Edit Record")
        }
        super.init(title: title, message: nil, style: .alert, actions: nil)
        self.actionsCountPerRow = 1
        self.actions = [doneAlertAction]
        self.additionalView = self.recordInputView
        self.additionalSize = CGSize(width: .greatestFiniteMagnitude, height: 260.0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDoneActionEnabled()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func handleFirstAppearance() {
        super.handleFirstAppearance()
        recordInputView.textField.becomeFirstResponder()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recordInputView.textField.resignFirstResponder()
        recordInputView.remarkTextView.resignFirstResponder()
    }

    // MARK: - Actions
    override func clickDone() {
        TPImpactFeedback.impactWithSoftStyle()
        /// 取消第一响应者
        UIResponder.resignCurrentFirstResponder()
        /// dismiss 完成后通知结束编辑
        dismiss(animated: true) {
            self.didEndEditing()
        }
    }

    func didEndEditing() {
        guard let completion = completion else {
            return
        }

        if let number = recordInputView.number {
            completion(number.int64Value, inputType, recordInputView.remark)
        }
    }

    func updateDoneActionEnabled() {
        var isEnabled = false
        if let number = recordInputView.number {
            if inputType == .update {
                /// 更新（总量）模式：允许输入 0
                isEnabled = number.int64Value >= 0
            } else {
                /// 增量模式：需要大于 0 的数值
                isEnabled = number.int64Value > 0
            }
        }

        doneAlertAction.isEnabled = isEnabled
    }

    // MARK: - Event Response
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        updateDoneActionEnabled()
    }
}

/// 目标任务记录输入视图（类型菜单 + 数值输入框 + 备注文本视图）
class GoalRecordInputView: UIView, UITextViewDelegate {

    /// 数值
    var number: NSNumber? {
        return numberField.number
    }

    /// 数值输入框
    var textField: TPTextField {
        return numberField.textField
    }

    /// 备注文本
    var remark: String? {
        let string = remarkTextView.text.whitespacesAndNewlinesTrimmedString
        guard !string.isEmpty else {
            return nil
        }

        return string
    }

    /// 备注输入内容变化回调
    var remarkEditingChanged: (() -> Void)?

    /// 输入类型变化回调
    var inputTypeDidChange: (() -> Void)?
    
    /// 设置备注文本（用于编辑既有记录时预填）
    func setRemark(_ text: String?) {
        remarkTextView.text = text
    }

    /// 记录输入类型
    var inputType: GoalRecordInputType {
        get {
            let tag = typeMenuView.selectedMenuTag ?? 0
            return GoalRecordInputType(rawValue: tag) ?? inputTypes[0]
        }

        set {
            if inputTypes.contains(newValue) {
                typeMenuView.selectMenu(withTag: newValue.rawValue)
            }

            updateTextField()
        }
    }

    let inputTypes: [GoalRecordInputType]

    /// 类型菜单视图
    private lazy var typeMenuView: TPSegmentedMenuView = {
        let view = TPSegmentedMenuView()
        view.cornerRadius = 16.0
        view.margin = 0.0
        view.padding = UIEdgeInsets(value: 5.0)
        view.didSelectMenuItem = { [weak self] menuItem in
            if let type = GoalRecordInputType(rawValue: menuItem.tag) {
                self?.selectInputType(type)
            }
        }

        return view
    }()

    /// 数值输入框
    private lazy var numberField: TPNumberField = {
        let numberField = TPNumberField()
        numberField.selectAllAtBeginning = false
        numberField.clipsToBounds = true
        return numberField
    }()

    /// 备注文本视图
    private(set) lazy var remarkTextView: TPTextView = {
        let textView = TPTextView()
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 15.0)
        textView.textColor = .label
        textView.textContainerInset = UIEdgeInsets(horizontal: 12.0, vertical: 12.0)
        textView.backgroundColor = .clear
        textView.placeholder = resGetString("Add Note")
        textView.placeholderColor = .tertiaryLabel
        textView.placeholderPosition = .topLeft
        textView.maxCount = 200
        textView.isScrollEnabled = true
        textView.alwaysBounceVertical = true
        textView.inputAccessoryView = textView.dismissToolbar
        return textView
    }()

    init(inputTypes: [GoalRecordInputType]) {
        self.inputTypes = inputTypes
        super.init(frame: .zero)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        typeMenuView.menuItems = inputTypes.segmentedMenuItems()
        addSubview(typeMenuView)
        addSubview(numberField)
        addSubview(remarkTextView)
        updateTextField()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrame = layoutFrame()

        typeMenuView.width = width
        typeMenuView.height = 50.0
        typeMenuView.minButtonWidth = (width - typeMenuView.padding.horizontalLength) / CGFloat(typeMenuView.menuItems.count)
        typeMenuView.top = layoutFrame.minY
        typeMenuView.normalBackgroundColor = .secondarySystemGroupedBackground

        numberField.width = width
        numberField.height = 50.0
        numberField.top = typeMenuView.bottom + 12.0
        numberField.layer.cornerRadius = 12.0
        numberField.layer.backgroundColor = UIColor.secondarySystemGroupedBackground.cgColor

        let remarkTop = numberField.bottom + 12.0
        remarkTextView.width = width
        remarkTextView.height = max(layoutFrame.maxY - remarkTop, 0.0)
        remarkTextView.top = remarkTop
        remarkTextView.layer.cornerRadius = 12.0
        remarkTextView.layer.backgroundColor = UIColor.secondarySystemGroupedBackground.cgColor
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        remarkEditingChanged?()
    }

    // MARK: - Private
    private func selectInputType(_ type: GoalRecordInputType) {
        updateTextField()
        inputTypeDidChange?()
    }

    func updateTextField() {
        var placeholder = ""
        switch inputType {
        case .increase:
            placeholder = resGetString("Increase the number of records")
        case .decrease:
            placeholder = resGetString("Decrease the number of records")
        case .update:
            placeholder = resGetString("Update the number of records")
        }

        textField.placeholder = placeholder
        /// 切换类型时保留用户已输入的数字，不清空输入框
    }
}
