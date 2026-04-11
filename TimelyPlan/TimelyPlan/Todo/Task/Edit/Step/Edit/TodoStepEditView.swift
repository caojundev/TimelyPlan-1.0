//
//  TodoStepEditView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/6.
//

import Foundation

class TodoStepEditView: TPKeyboardAwareView, UITextFieldDelegate {
    
    /// 点击Return
    var didEnterReturn: ((UITextField) -> Void)?
    
    /// 开始编辑时是否选择全部文本
    var selectAllAtBeginning: Bool = false
    
    /// 检查框尺寸
    let checkboxSize = CGSize(width: 20.0, height: 20.0)
    
    /// 检查框
    lazy var checkbox: TPSquareCheckbox = {
        let checkbox = TPSquareCheckbox()
        checkbox.cornerRadius = .greatestFiniteMagnitude
        checkbox.checkmarkLineWidth = 2.0
        checkbox.hitTestEdgeInsets = UIEdgeInsets(horizontal: -20.0, vertical: -20.0)
        checkbox.normalColor = Color(light: 0x646566, dark: 0xabacad)
        checkbox.checkedColor = .primary
        checkbox.padding = .zero
        checkbox.addTarget(self, action: #selector(clickCheckbox(_:)), for: .touchUpInside)
        return checkbox
    }()
    
    /// 文本输入
    private(set) lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.boldSystemFont(ofSize: 15.0)
        textField.textColor = Color(light: 0x232323,
                                    dark: 0xF2F2F2)
        textField.clearButtonMode = .whileEditing
        textField.placeholder = resGetString("Add Step")
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        textField.returnKeyType = .done
        return textField
    }()
    
    /// 添加位置
    var position: TodoStepAddPosition {
        get {
            return positionButton.position
        }
        
        set {
            positionButton.position = newValue
        }
    }
    
    private lazy var positionButton: TodoStepPositionButton = {
        let button = TodoStepPositionButton()
        button.addTarget(self, action: #selector(clickPosition(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        self.padding = UIEdgeInsets(top: 5.0, left: 35.0, bottom: 5.0, right: 16.0)
        self.contentSize = CGSize(width: .greatestFiniteMagnitude, height: 60.0)
        self.backgroundColor = resGetColor(.insetGroupedTableCellBackgroundNormal)
        self.addSubview(checkbox)
        self.addSubview(textField)
        self.addSubview(positionButton)
        self.addSeparator(position: .top) /// 顶部分割线
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = self.safeLayoutFrame()
        checkbox.size = checkboxSize
        checkbox.right = layoutFrame.minX + 10.0
        checkbox.centerY = layoutFrame.midY
    
        positionButton.sizeToFit()
        positionButton.right = layoutFrame.maxX
        positionButton.centerY = layoutFrame.midY
        
        let textFieldLeft = checkbox.right + 15.0
        textField.width = positionButton.left - textFieldLeft - 10.0
        textField.height = layoutFrame.height
        textField.left = textFieldLeft
        textField.top = layoutFrame.minY
    }
    
    // MARK: - Event Response
    
    /// 点击checkbox
    @objc func clickCheckbox(_ button: UIButton) {
        let isChecked = !checkbox.isChecked
        checkbox.setChecked(isChecked, animated: true)
    }
    
    @objc func clickPosition(_ button: TodoStepPositionButton) {
        var position: TodoStepAddPosition = .bottom
        if button.position == .bottom {
            position = .top
        }
        
        button.setPosition(position, animated: true)
        
        /// 文本提示
        var message: String
        if position == .bottom {
            message = resGetString("Add step to bottom")
        } else {
            message = resGetString("Add step to top")
        }

        TPFeedbackQueue.common.postFeedback(text: message, position: .top)
    }
    
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.didEnterReturn?(textField)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if selectAllAtBeginning {
            textField.perform(#selector(UITextField.selectAll(_:)), with: textField, afterDelay: 0.1)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

    }
    
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        
    }
}
