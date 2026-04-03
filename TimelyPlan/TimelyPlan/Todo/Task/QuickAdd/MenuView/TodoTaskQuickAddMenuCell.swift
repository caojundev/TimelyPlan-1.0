//
//  TodoTaskQuickAddMenuCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/23.
//

import Foundation

class TodoTaskQuickAddMenuCellItem: TPImageInfoCollectionCellItem {
    
    var isActive: Bool = false
    
    var didClickDelete: (() -> Void)?
    
    /// 正常单元格颜色
    lazy var normalCellStyle: TPCollectionCellStyle = {
        let style = TPCollectionCellStyle()
        style.cornerRadius = .greatestFiniteMagnitude
        style.backgroundColor = .clear
        style.selectedBackgroundColor = .clear
        return style
    }()
    
    /// 活动单元格颜色
    lazy var activeCellStyle: TPCollectionCellStyle = {
        let style = TPCollectionCellStyle()
        style.cornerRadius = .greatestFiniteMagnitude
        style.backgroundColor = .primary
        style.selectedBackgroundColor = .primary
        return style
    }()
    
    var normalTitleConfig: TPLabelConfig = .titleConfig
    
    lazy var activeTitleConfig: TPLabelConfig = {
        let config = TPLabelConfig.titleConfig
        config.textColor = .white
        return config
    }()
    
    override var titleConfig: TPLabelConfig {
        get {
            return isActive ? activeTitleConfig : normalTitleConfig
        }
        
        set {}
    }
    
    override var style: TPCollectionCellStyle? {
        get {
            return isActive ? activeCellStyle : normalCellStyle
        }
        
        set {}
    }
    
    override var registerClass: UICollectionViewCell.Type {
        get {
            return TodoTaskQuickAddMenuCell.self
        }
        
        set {}
    }

    override var size: CGSize? {
        get {
            return isActive ? activeItemSize() : .size(8)
        }
        
        set {}
    }
    
    override var rightAccessorySize: CGSize {
        get {
            return isActive ? .size(3) : .zero
        }
        
        set {}
    }
    
    override var rightAccessoryMargins: UIEdgeInsets {
        get {
            return isActive ? UIEdgeInsets(value: 5.0) : .zero
        }
        
        set {}
    }
    
    let actionType: TodoTaskQuickAddMenuActionType
    
    init(actionType: TodoTaskQuickAddMenuActionType) {
        self.actionType = actionType
        super.init()
        self.contentPadding = UIEdgeInsets(left: 8.0, right: 8.0)
        self.titleConfig.font = UIFont.boldSystemFont(ofSize: 12.0)
    }

    func activeItemSize() -> CGSize {
        var width = contentPadding.horizontalLength
        width += imageConfig.size.width + imageConfig.margins.horizontalLength
        width += rightAccessorySize.width + rightAccessoryMargins.horizontalLength
        var titleWidth: CGFloat = 0.0
        if let attributedTitle = title as? ASAttributedString {
           titleWidth = attributedTitle.value.width(with: titleConfig.font)
        } else if let title = title as? String{
            titleWidth = title.width(with: titleConfig.font)
        }
    
        width += titleWidth
        return CGSize(width: width, height: 32.0)
    }
}

protocol TodoTaskQuickAddMenuCellDelegate: AnyObject {
 
    /// 点击删除
    func todoTaskQuickAddMenuCellDidClickDelete(_ cell: TodoTaskQuickAddMenuCell)
}

class TodoTaskQuickAddMenuCell: TPImageInfoCollectionCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            guard let cellItem = cellItem as? TodoTaskQuickAddMenuCellItem else {
                return
            }
            
            isActive = cellItem.isActive
            didClickDelete = cellItem.didClickDelete
            setNeedsLayout()
        }
    }
    
    /// 活动状态删除按钮尺寸
    var activeDeleteButtonSize: CGSize = .size(3)
    
    /// 点击删除
    var didClickDelete: (() -> Void)?
    
    /// 是否活动
    var isActive: Bool = false {
        didSet {
            updateRightAccessoryView()
        }
    }
    
    private lazy var deleteButton: TPImageButton = {
        let button = TPImageButton()
        button.normalImage = resGetImage("xmark_circle_fill_12")
        button.hitTestEdgeInsets = UIEdgeInsets(value: -12.0)
        button.normalImageColor = Color(0xFFFFFF, 0.8)
        button.addTarget(self, action: #selector(clickDelete(_:)), for: .touchUpInside)
        return button
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        infoView.rightAccessoryView = deleteButton
        updateRightAccessoryView()
    }
    
    private func updateRightAccessoryView() {
        if isActive {
            infoView.rightAccessorySize = activeDeleteButtonSize
            infoView.rightAccessoryView?.isHidden = false
        } else {
            infoView.rightAccessorySize = .zero
            infoView.rightAccessoryView?.isHidden = true
        }
    }
    
    @objc private func clickDelete(_ button: UIButton) {
        didClickDelete?()
        if let delegate = delegate as? TodoTaskQuickAddMenuCellDelegate {
            delegate.todoTaskQuickAddMenuCellDidClickDelete(self)
        }
    }
}
