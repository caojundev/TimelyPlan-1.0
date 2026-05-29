//
//  TodoTaskBaseTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/13.
//

import Foundation
import UIKit

class TodoTaskBaseTableCell: UITableViewCell,
                             Checkable,
                             FocusAnimatable,
                             SearchHighlightable {
    
    weak var delegate: AnyObject?

    /// 布局对象
    var layout: TodoTaskInfoLayout?
    
    var task: TodoTask? {
        return layout?.task
    }

    /// 信息视图
    var infoView: TodoTaskBaseInfoView!
    
    private var modificationDate: Date?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundView = UIView()
        self.selectedBackgroundView = UIView()
        self.multipleSelectionBackgroundView = UIView()
        self.backgroundView?.backgroundColor = .secondarySystemGroupedBackground
        self.selectedBackgroundView?.backgroundColor = .tertiarySystemGroupedBackground
        self.multipleSelectionBackgroundView?.backgroundColor = .secondarySystemGroupedBackground
        setupContentSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupContentSubviews() {
        contentView.addSubview(infoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = bounds
       
        /// 更新信息视图布局
        if let layout = layout {
           layout.layoutIfNeeded()
           infoView.updateLayout(with: layout)
        }

        updateHighlightedName()
    }
    
    func reloadDataIfNeeded(animated: Bool) {
        guard modificationDate != task?.modificationDate else {
            return
        }
        
        reloadData(animated: animated)
    }
    
    func reloadData(animated: Bool) {
        modificationDate = task?.modificationDate
        guard let layout = layout else {
            return
        }

        infoView.updateContent(with: layout, animated: animated)
        setNeedsLayout()
    }
    
    // MARK: - Completed
    var isCompleted: Bool {
        return infoView.isCompleted
    }
    
    func setCompleted(_ isCompleted: Bool,
                      animated: Bool = false,
                      completion: (() -> Void)? = nil) {
        infoView.setCompleted(isCompleted,
                              animated: animated,
                              completion: completion)
    }
    
    func setProgress(_ progress: CGFloat,
                     animated: Bool = false,
                     completion: (() -> Void)? = nil) {
        infoView.setProgress(progress,
                             animated: animated,
                             completion: completion)
    }
    
    // MARK: - Checkable
    private var _isChecked: Bool = false
    var isChecked: Bool {
        get { return _isChecked }
        set { setChecked(newValue, animated: false) }
    }
    
    func setChecked(_ checked: Bool, animated: Bool) {
        _isChecked = checked
    }
    
    // MARK: - FocusAnimatable
    
    var focusCornerRadius: CGFloat {
        return 12.0
    }
    
    var focusPadding: UIEdgeInsets {
        return UIEdgeInsets(value: 2.0)
    }
    
    var focusLineWidth: CGFloat {
        return 1.6
    }
    
    // MARK: - SearchHighlightable
    
    /// 高亮文本
    var highlightedText: String?
    
    /// 高亮普通文本属性
    var normalAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: infoView.nameLabel.currentTextColor,
            .font: infoView.nameLabel.font ?? BOLD_SYSTEM_FONT
        ]
    }

    /// 高亮文本属性
    var highlightAttributes: [NSAttributedString.Key: Any] {
        return [
            .backgroundColor: Color(0xFFD60A),
            .foregroundColor: UIColor.black,
            .font: infoView.nameLabel.font ?? BOLD_SYSTEM_FONT
        ]
    }
    
    /// 设置搜索文本并更新高亮显示
    func setHighlightedText(_ highlightedText: String?) {
        self.highlightedText = highlightedText
        setNeedsLayout()
    }
    
    /// 更新高亮名称
    func updateHighlightedName() {
        guard let highlightedText = highlightedText,
              highlightedText.count > 0,
              let name = infoView.name else {
            return
        }
        
        let searchRange = NSString(string: name).range(of: highlightedText)
        if searchRange.location == NSNotFound {
            return
        }
        
        let attributedName = name.attributedStringWithHighlight(highlightedText,
                                                                normalAttributes: normalAttributes,
                                                                highlightAttributes: highlightAttributes)
        self.infoView.attributedName = attributedName
    }
}
