//
//  TodoTaskNameEditView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/11.
//

import Foundation
import UIKit

protocol TodoTaskEditNameViewDelegate: AnyObject {
    
    func todoTaskEditNameViewDidClickCheckbox(_ nameView: TodoTaskEditNameView)
    
    func todoTaskEditNameViewEditingChanged(_ nameView: TodoTaskEditNameView)
    
    func todoTaskEditNameViewDidEndEditing(_ nameView: TodoTaskEditNameView)
}

class TodoTaskEditNameView: UIView {
    
    /// 代理对象
    weak var delegate: TodoTaskEditNameViewDelegate?
    
    /// 任务名称
    var name: String? {
        get {
            return textView.text.whitespacesAndNewlinesTrimmedString
        }
        
        set {
            textView.text = newValue?.whitespacesAndNewlinesTrimmedString
            textView.setNeedsLayout() /// 划线需要重新布局
        }
    }
    
    /// 是否已完成
    var isCompleted: Bool {
        get {
            return checkbox.isChecked
        }
        
        set {
            setCompleted(newValue, animated: false)
        }
    }
    
    /// 检查类型
    var checkType: TodoTaskCheckType = .normal {
        didSet {
            switch checkType {
            case .normal:
                checkbox.mode = .normal
            case .increase:
                checkbox.mode = .plus
            case .decrease:
                checkbox.mode = .minus
            }
        }
    }
    
    /// 优先级
    var priority: TodoTaskPriority = .none {
        didSet {
            updateCheckboxStyle()
        }
    }

    /// 文本字体
    var font: UIFont {
        get {
            return textView.font ?? BOLD_BODY_FONT
        }
        
        set {
            textView.font = newValue
        }
    }

    /// 最大高度
    var maximumHeight: CGFloat = .greatestFiniteMagnitude
    
    var contentHeight: CGFloat {
        layout.text = name
        layout.font = font
        layout.padding = padding
        layout.textContainerInset = textView.textContainerInset
        layout.width = width
        layout.maximumHeight = maximumHeight
        return layout.height
    }
    
    /// 检查按钮
    private(set) lazy var checkbox: TodoTaskCheckbox = {
        let checkbox = TodoTaskCheckbox()
        checkbox.hitTestEdgeInsets = UIEdgeInsets(horizontal: -20.0, vertical: -20.0)
        checkbox.padding = .zero
        checkbox.addTarget(self,
                         action: #selector(clickCheckbox(_:)),
                         for: .touchUpInside)
        return checkbox
    }()
    
    /// 文本视图
    private lazy var textView: TodoTaskEditNameTextView = {
        let textView = TodoTaskEditNameTextView()
        textView.font = BOLD_BODY_FONT
        textView.editingChanged = { [weak self] textView in
            self?.textViewEditingChanged(textView)
        }
        
        textView.didEndEditing = { [weak self] textView in
            self?.textViewDidEndEditing(textView)
        }
        
        return textView
    }()
    
    /// 布局对象
    private let layout = TodoTaskEditNameLayout()
    
    /// checkbox 按钮尺寸
    private let checkboxSize = CGSize(width: 20.0, height: 20.0)
    private let checkboxLeftMargin = 20.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func setupSubviews() {
        padding = UIEdgeInsets(top: 5.0, left: 55.0, bottom: 5.0, right: 10.0)
        addSubview(checkbox)
        addSubview(textView)
        updateCheckboxStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let textLayoutFrame = self.layoutFrame()
        checkbox.size = checkboxSize
        checkbox.left = checkboxLeftMargin
        checkbox.centerY = textLayoutFrame.minY + textView.textContainerInset.top + font.lineHeight / 2.0
        textView.frame = textLayoutFrame
    }
    
    private func updateCheckboxStyle() {
        let color = priority.titleColor
        checkbox.normalColor = color
        checkbox.checkedColor = color
    }
    
    // MARK: - Event Response
    
    func textViewEditingChanged(_ textView: UITextView) {
        delegate?.todoTaskEditNameViewEditingChanged(self)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.todoTaskEditNameViewDidEndEditing(self)
    }
    
    @objc private func clickCheckbox(_ button: UIButton) {
        delegate?.todoTaskEditNameViewDidClickCheckbox(self)
    }
    
    // MARK: - Public Methods
    func setCompleted(_ isCompleted: Bool, animated: Bool = false) {
        checkbox.setChecked(isCompleted, animated: animated)
        textView.setStrikethrough(isCompleted, animated: animated)
        self.setNeedsLayout()
    }
}

class TodoTaskEditNameLayout {
    
    /// 文本
    var text: String? {
        didSet {
            if text != oldValue {
                needsLayout = true
            }
        }
    }
    
    /// 字体
    var font: UIFont = BOLD_BODY_FONT {
        didSet {
            if font != oldValue {
                needsLayout = true
            }
        }
    }

    /// 文本容器间距
    var textContainerInset: UIEdgeInsets = .zero {
        didSet {
            if textContainerInset != oldValue {
                needsLayout = true
            }
        }
    }

    /// 内容内间距
    var padding: UIEdgeInsets = .zero {
        didSet {
            if padding != oldValue {
                needsLayout = true
            }
        }
    }
    
    /// 最大高度
    var maximumHeight: CGFloat = .greatestFiniteMagnitude {
        didSet {
            if maximumHeight != oldValue {
                needsLayout = true
            }
        }
    }

    /// 内容宽度
    var width: CGFloat? {
        didSet {
            if width != oldValue {
                needsLayout = true
            }
        }
    }
    
    /// 高度
    var height: CGFloat {
        guard needsLayout else {
            return validatedHeight(_height)
        }
        
        guard let width = width else {
            _height = validatedHeight(0.0)
            needsLayout = false
            return _height
        }

        needsLayout = false
        let layoutWidth = width - textContainerInset.horizontalLength - padding.horizontalLength
        let maxSize = CGSize(width: layoutWidth, height: .greatestFiniteMagnitude)
        let textSize = text?.size(with: font, maxSize: maxSize) ?? .zero
        let contentHeight = ceil(textSize.height) + textContainerInset.verticalLength + padding.verticalLength
        _height = validatedHeight(contentHeight)
        return _height
    }
    
    /// 最小高度
    var minimumHeight: CGFloat {
        return font.lineHeight + textContainerInset.verticalLength + padding.verticalLength
    }
    
    private var needsLayout: Bool = true
    
    private var _height: CGFloat = 0.0
    
    private func validatedHeight(_ height: CGFloat) -> CGFloat {
        return min(maximumHeight, max(height, minimumHeight))
    }
}
