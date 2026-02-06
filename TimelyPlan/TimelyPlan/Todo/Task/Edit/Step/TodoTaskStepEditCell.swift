//
//  TodoTaskStepCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/30.
//

import Foundation

class TodoTaskStepEditCellItem: TPAutoResizeTextViewTableCellItem {

    let step: TodoStep
    
    init(step: TodoStep) {
        self.step = step
        super.init()
        self.identifier = step.identifier ?? UUID().uuidString
        self.text = step.name
        self.registerClass = TodoTaskStepEditCell.self
        self.leftViewMargins = UIEdgeInsets(left: 14.0, right: 10.0)
        self.leftViewSize = .size(5)
        self.rightViewSize = .mini
        self.placeholder = resGetString("")
        self.isNewlineEnabled = false
        self.font = SYSTEM_FONT
    }
    
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? TodoTaskStepEditCellItem {
            return self.step === object.step
        }
        
        return false
    }
}

protocol TodoTaskStepEditCellDelegate: TPTextViewTableCellDelegate {
    
    /// 点击Checkbox
    func stepEditCellDidClickCheckbox(_ cell: TodoTaskStepEditCell)
    
    /// 点击更多
    func stepEditCellDidClickMore(_ cell: TodoTaskStepEditCell)
}

class TodoTaskStepEditCell: TPTextViewTableCell {

    override var cellItem: TPBaseTableCellItem? {
        didSet {
            let cellItem = cellItem as! TodoTaskStepEditCellItem
            self.step = cellItem.step
            self.updateCompleted(animated: false)
            self.setNeedsLayout()
        }
    }
    
    var step: TodoStep?

    /// 检查框
    lazy var checkbox: TPSquareCheckbox = {
        let checkbox = TPSquareCheckbox()
        checkbox.cornerRadius = .greatestFiniteMagnitude
        checkbox.checkmarkLineWidth = 2.0
        checkbox.hitTestEdgeInsets = UIEdgeInsets(horizontal: -10.0, vertical: -10.0)
        checkbox.normalColor = .secondaryLabel
        checkbox.checkedColor = .primary
        checkbox.padding = .zero
        checkbox.addTarget(self,
                         action: #selector(clickCheckbox(_:)),
                         for: .touchUpInside)
        return checkbox
    }()
    
    /// 文本视图
    lazy var strikethroughTextView: TPStrikethroughTextView = {
        let textView = TPStrikethroughTextView()
        textView.isUserInteractionEnabled = false
        textView.delegate = self
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.textContainerInset = .zero
        textView.backgroundColor = .clear
        textView.textContainer.lineFragmentPadding = 0
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.returnKeyType = .done
        return textView
    }()
    
    /// 更多按钮
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.imageConfig.color = .secondaryLabel
        button.addTarget(self, action: #selector(clickMore(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 聚焦视图圆角半径
    override var focusCornerRadius: CGFloat {
        return 8.0
    }
    
    override func setupContentSubviews() {
        self.textView = self.strikethroughTextView
        super.setupContentSubviews()
        self.leftView = checkbox
        self.leftViewMargins = UIEdgeInsets(left: 10.0, right: 10.0)
        self.leftViewSize = .mini
        self.rightView = moreButton
        self.rightViewSize = .mini
    }
    
    override func textViewDidBeginEditing(_ textView: UITextView) {
        super.textViewDidBeginEditing(textView)
        textView.isUserInteractionEnabled = true
        moreButton.isUserInteractionEnabled = false
        moreButton.alpha = 0.2
    }
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        super.textViewDidEndEditing(textView)
        textView.isUserInteractionEnabled = false
        moreButton.isUserInteractionEnabled = true
        moreButton.alpha = 1.0
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        self.strikethroughTextView.setNeedsLayout()
    }
    
    override func textViewDidEnterReturn(_ textView: UITextView) {
        super.textViewDidEnterReturn(textView)
        textView.resignFirstResponder()
    }
    
    // MARK: - 文本编辑
    func setTextEditing(_ isEditing: Bool) {
        if isEditing {
            self.textView.becomeFirstResponder()
        } else {
            self.textView.resignFirstResponder()
        }
    }
    
    // MARK: - Update
    func updateCompleted(animated: Bool = false) {
        let isCompleted = self.step?.isCompleted ?? false
        checkbox.setChecked(isCompleted, animated: animated)
        strikethroughTextView.setStrikethrough(isCompleted, animated: animated)
        self.setNeedsLayout()
    }
    
    
    // MARK: - Event Response
    /// 点击checkbox
    @objc func clickCheckbox(_ button: UIButton) {
        if let delegate = self.delegate as? TodoTaskStepEditCellDelegate {
            delegate.stepEditCellDidClickCheckbox(self)
        }
    }
    
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        if let delegate = self.delegate as? TodoTaskStepEditCellDelegate {
            delegate.stepEditCellDidClickMore(self)
        }
    }
}
