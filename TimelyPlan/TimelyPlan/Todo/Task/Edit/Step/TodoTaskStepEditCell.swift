//
//  TodoTaskStepCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/30.
//

import Foundation

class TodoTaskStepEditCellItem: TPAutoResizeTextViewTableCellItem {
    
    /// 展开按钮尺寸
    var expandButtonSize: CGSize = .mini
    
    var depthWidth: CGFloat = 32.0
    
    let step: TodoStep
    
    init(step: TodoStep) {
        self.step = step
        super.init()
        self.depth = step.depth
        self.identifier = step.id
        self.text = step.content
        self.registerClass = TodoTaskStepEditCell.self
        self.placeholder = resGetString("")
        self.isNewlineEnabled = false
        self.font = SYSTEM_FONT
        self.returnKeyType = .next
        self.maxCount = 120
        
        self.leftViewMargins = UIEdgeInsets(left: 14.0, right: 10.0)
        self.leftViewSize = .size(5)
        self.rightViewSize = .mini
        self.rightViewMargins = UIEdgeInsets(right: 10.0)
        self.depthWidth = 32.0
    }
    
    override func textContentWidth() -> CGFloat? {
        guard var width = super.textContentWidth() else {
            return nil
        }
        
        /// 减去缩进宽度
        width -= CGFloat(step.depth) * depthWidth
        
        /// 减去展开按钮宽度
        if step.hasSubItem {
            width -= expandButtonSize.width
        }
        
        return width
    }
    
    // MARK: - ListDiffable
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
    
    /// 切换展开状态
    func stepEditCell(_ cell: TodoTaskStepEditCell, didToggleExpand isExpanded: Bool)
}

class TodoTaskStepEditCell: TPTextViewTableCell {

    override var cellItem: TPBaseTableCellItem? {
        didSet {
            let cellItem = cellItem as! TodoTaskStepEditCellItem
            self.step = cellItem.step
            self.depthWidth = cellItem.depthWidth
            self.depthLineLayer.indentationLevel = cellItem.depth
            self.updateCompleted(animated: false)
            self.expandButtonSize = cellItem.expandButtonSize
            self.updateExpandedButton()
            self.setNeedsLayout()
        }
    }
    
    var step: TodoStep?
    
    /// 深度绘制层级
    var depthLineLevels: [Int]? {
        get {
            return depthLineLayer.depthLineLevels
        }
        
        set {
            depthLineLayer.depthLineLevels = newValue
        }
    }
    
    /// 缩进分割线图层
    private(set) lazy var depthLineLayer: TodoListBranchLayer = {
        let layer = TodoListBranchLayer()
        layer.indentationWidth = depthWidth
        layer.lineWidth = 2.0
        layer.strokeColor = UIColor.lightGray.cgColor
        return layer
    }()
    
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
        textView.returnKeyType = .next
        return textView
    }()
    
    /// 更多按钮
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.imageConfig.color = .secondaryLabel
        button.addTarget(self, action: #selector(clickMore(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 展开按钮
    var expandButtonSize: CGSize = .mini
    
    private(set) lazy var expandButton: TPChevronExpandButton = {
        let button = TPChevronExpandButton()
        button.padding = .zero
        button.image = resGetImage("todo_home_expand_18")
        button.imageConfig.color = .systemGray3
        button.hitTestEdgeInsets = UIEdgeInsets(value: -10.0)
        button.addTarget(self,
                         action: #selector(clickExpand(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    /// 聚焦视图圆角半径
    override var focusCornerRadius: CGFloat {
        return 8.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        depthLineLayer.frame = CGRect(x: 0.0, y: 0.0, width: contentView.left, height: bounds.height)
        depthLineLayer.dx = checkbox.centerX - depthWidth
        depthLineLayer.indentationWidth = depthWidth
        CATransaction.commit()
        
        expandButton.size = expandButtonSize
        expandButton.left = textView.right
        expandButton.alignVerticalCenter()
    }

    override func availableLayoutFrame() -> CGRect {
        var layoutFrame = super.availableLayoutFrame()
        guard let step = step, step.hasSubItem else {
            return layoutFrame
        }

        layoutFrame.size.width = layoutFrame.size.width - expandButtonSize.width
        return layoutFrame
    }
    
    override func setupContentSubviews() {
        self.textView = self.strikethroughTextView
        super.setupContentSubviews()
        self.leftView = checkbox
        self.rightView = moreButton
        self.contentView.addSubview(expandButton)
        self.layer.addSublayer(depthLineLayer)
    }
    
    override func textViewDidBeginEditing(_ textView: UITextView) {
        super.textViewDidBeginEditing(textView)
        textView.isUserInteractionEnabled = true
        updateButtonStatus(isEditing: true)
    }
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        super.textViewDidEndEditing(textView)
        textView.isUserInteractionEnabled = false
        updateButtonStatus(isEditing: false)
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
    
    private func updateExpandedButton() {
        guard let step = step else {
            expandButton.isHidden = true
            expandButton.setExpanded(true, animated: false)
            return
        }

        let isHidden = step.subSteps.count == 0
        expandButton.isHidden = isHidden
        expandButton.setExpanded(step.isExpanded, animated: false)
    }
    
    private func updateButtonStatus(isEditing: Bool) {
        let isUserInteractionEnabled = !isEditing
        let alpha = isEditing ? 0.2 : 1.0
        moreButton.isUserInteractionEnabled = isUserInteractionEnabled
        moreButton.alpha = alpha
        expandButton.isUserInteractionEnabled = isUserInteractionEnabled
        expandButton.alpha = alpha
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
    
    /// 点击展开或收起按钮
    @objc private func clickExpand(_ button: UIButton) {
        let isExpanded = !expandButton.isExpanded
        setExpanded(isExpanded, animated: true)
        if let delegate = self.delegate as? TodoTaskStepEditCellDelegate {
            delegate.stepEditCell(self, didToggleExpand: isExpanded)
        }
    }

    // MARK: - Public Methods
    /// 动画更新展开状态
    func setExpanded(_ isExpanded: Bool, animated: Bool) {
        guard expandButton.isExpanded != isExpanded else {
            return
        }
        
        expandButton.setExpanded(isExpanded, animated: animated)
    }
}

extension TodoTaskStepEditCell: TPDragPreviewViewProviding {
    
    func dragPreviewView() -> UIView? {
        let view = TodoTaskStepEditCellPreviewView(frame: contentView.frame)
        view.padding = self.contentPadding
        view.infoView.titleConfig.font = self.textView.font ?? SYSTEM_FONT
        view.infoView.leftAccessoryMargins = self.leftViewMargins
        view.infoView.leftAccessorySize = self.leftViewSize
        view.infoView.title = self.textView.text
        view.checkbox.isChecked = self.checkbox.isChecked
        return view
    }
    
    func beginFrame() -> CGRect {
        currentFrame()
    }
    
    func endFrame() -> CGRect {
        currentFrame()
    }
    
    private func currentFrame() -> CGRect {
        let x = CGFloat(self.depth) * depthWidth
        let w = self.width - x
        return CGRect(x: x, y: 0.0, width: w, height: self.height)
    }
}

class TodoTaskStepEditCellPreviewView: UIView {

    /// 检查框
    lazy var checkbox: TPSquareCheckbox = {
        let checkbox = TPSquareCheckbox()
        checkbox.cornerRadius = .greatestFiniteMagnitude
        checkbox.checkmarkLineWidth = 2.0
        checkbox.normalColor = .secondaryLabel
        checkbox.checkedColor = .primary
        checkbox.padding = .zero
        return checkbox
    }()
    
    let infoView = TPInfoView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .secondarySystemBackground
        self.infoView.leftAccessoryView = self.checkbox
        self.addSubview(infoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.infoView.frame = layoutFrame()
    }
}
