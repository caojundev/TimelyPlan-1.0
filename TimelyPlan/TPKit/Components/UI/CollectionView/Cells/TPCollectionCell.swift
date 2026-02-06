//
//  TPCollectionCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/6.
//

import Foundation
import UIKit

class TPCollectionCellItem: NSObject {

    /// 唯一标识
    lazy var identifier: String = {
        return UUID().uuidString
    }()
    
    /// 单元格注册类
    var registerClass: UICollectionViewCell.Type = TPCollectionCell.self

    /// 单元格代理对象
    weak var delegate: AnyObject?
    
    /// 整数标签，可用于标记单元格
    var tag: Int = 0
    
    /// 是否选中
    var isChecked: Bool = false
    
    /// 是否禁用
    var isDisabled: Bool = false
    
    /// 单元格是否高亮
    var canHighlight: Bool = true
    
    /// 高亮是否缩放
    var scaleWhenHighlighted: Bool = true
    
    /// 单元格样式
    var style: TPCollectionCellStyle?
    
    /// 单元格内间距
    var contentPadding: UIEdgeInsets = .zero
    
    /// 单元格最大约束尺寸
    var constraintSize: CGSize?
    
    /// 单元格尺寸
    var size: CGSize?
    
    /// 单元格高度
    var height: CGFloat {
        get {
            return size?.height ?? 0.0
        }
        
        set {
            var size = size ?? CGSize(width: .greatestFiniteMagnitude, height: 0.0)
            size.height = newValue
            self.size = size
        }
    }
    
    /// 单元格条目更新方法
    var updater: (() -> Void)?
    
    /// 选中该单元格回调
    var didSelectHandler: (() -> Void)?
    
    convenience init(registerClass: UICollectionViewCell.Type) {
        self.init()
        self.registerClass = registerClass
    }
    
    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? TPCollectionCellItem else {
            return false
        }

        return identifier == object.identifier
    }
}


protocol TPCollectionCellDelegate {
    /// 执行菜单操作
    func collectionCell(_ cell: TPCollectionCell, perfomMenuAction type: TPCollectionCell.MenuActionType)
}

class TPCollectionCell: UICollectionViewCell,
                            Checkable,
                            FocusAnimatable {
    
    let kDisabledContentAlpha = 0.3

    /// 单元格代理对象
    weak var delegate: AnyObject?
    
    /// 高亮是否缩放
    var scaleWhenHighlighted: Bool = true
    
    /// 是否禁用
    var isDisabled: Bool = false {
        didSet {
            let alpha = isDisabled ? kDisabledContentAlpha : 1.0
            backgroundView?.alpha = alpha
            contentView.alpha = alpha
        }
    }
    
    var cellStyle: TPCollectionCellStyle? {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 单元格条目
    var cellItem: TPCollectionCellItem? {
        didSet {
            contentView.padding = cellItem?.contentPadding ?? .zero
            scaleWhenHighlighted = cellItem?.scaleWhenHighlighted ?? true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.backgroundView = UIView()
        self.backgroundView?.clipsToBounds = true
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.clipsToBounds = true
        self.setupContentSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupContentSubviews() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCellStyle()
    }
    
    override var isHighlighted: Bool {
        didSet {
            if scaleWhenHighlighted {
                var transform: CGAffineTransform = .identity
                if isHighlighted {
                    var width = bounds.width
                    if width == 0 {
                        width = UIScreen.main.bounds.size.width
                    }
                    
                    let scale = (width - 4.0) / width
                    transform = .init(scaleX: scale, y: scale)
                }
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {
                    self.transform = transform
                }, completion: nil)
            }
            
            updateCellStyle()
        }
    }

    func updateCellStyle() {
        guard let cellStyle = cellStyle else {
            return
        }
        
        self.tintColor = cellStyle.tintColor
        self.backgroundView?.layer.borderWidth = cellStyle.borderWidth
        self.selectedBackgroundView?.layer.borderWidth = cellStyle.borderWidth
    
        let selectedBackgroundColor = cellStyle.selectedBackgroundColor ?? cellStyle.backgroundColor?.withAdjustedBrightness(by: -0.05)
        let selectedBorderColor = cellStyle.selectedBorderColor ?? cellStyle.borderColor?.withAdjustedBrightness(by: -0.05)
        selectedBackgroundView?.backgroundColor = selectedBackgroundColor
        selectedBackgroundView?.layer.borderColor = selectedBorderColor?.cgColor
 
        if isChecked {
            backgroundView?.layer.backgroundColor = selectedBackgroundColor?.cgColor
            backgroundView?.layer.borderColor = selectedBorderColor?.cgColor
        } else {
            backgroundView?.layer.backgroundColor = cellStyle.backgroundColor?.cgColor
            backgroundView?.layer.borderColor = cellStyle.borderColor?.cgColor
        }
        
        /// 更新圆角半径
        var cornerRadius = cellStyle.cornerRadius
        cornerRadius = min(cornerRadius, contentView.size.shortSideLength / 2.0)
        backgroundView?.layer.cornerRadius = cornerRadius
        selectedBackgroundView?.layer.cornerRadius = cornerRadius
        contentView.layer.cornerRadius = cornerRadius
        contentView.clipsToBounds = true
    }
    
    // MARK: - 显示
    func willDisplay() {
        
    }
    
    func didEndDisplay() {
        
    }
    
    // MARK: - Checkable 协议
    private var _isChecked: Bool = false
    var isChecked: Bool {
        get { return _isChecked }
        set { setChecked(newValue, animated: false) }
    }
    
    func setChecked(_ checked: Bool, animated: Bool) {
        _isChecked = checked
        /// 重新布局，更新单元格样式
        setNeedsLayout()
    }
    
    // MARK: - FocusAnimatable
    var focusPadding: UIEdgeInsets {
        return UIEdgeInsets(horizontal: 1.0, vertical: 1.0)
    }
    
    var focusCornerRadius: CGFloat {
        return cellStyle?.cornerRadius ?? 0.0
    }
    
    /// 线条宽度
    var focusLineWidth: CGFloat {
        return 2.5
    }
    
    /// 线条颜色
    var focusLineColor: UIColor {
        return .primary
    }
    
    // MARK: - 菜单操作
    enum MenuActionType: Int, CaseIterable {
        case edit   /// 编辑
        case delete /// 删除
        
        /// 菜单标题
        var title: String {
            switch self {
            case .edit:
                return resGetString("Edit")
            case .delete:
                return resGetString("Delete")
            }
        }
        
        /// 菜单动作
        var action: Selector {
            switch self {
            case .edit:
                return #selector(handleEdit(_:))
            case .delete:
                return #selector(handleDelete(_:))
            }
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        for menuActionType in MenuActionType.allCases {
            if action == menuActionType.action {
                return true
            }
        }
        
        return false
    }
    
    func showMenu(with actionTypes: [MenuActionType]) {
        becomeFirstResponder()
        /// 弹出空白菜单，修复点击菜单不弹出问题
        UIMenuController.shared.menuItems = nil
        UIMenuController.shared.showMenu(from: self, rect: self.bounds)
        
        var menuItems: [UIMenuItem] = []
        for actionType in actionTypes {
            let menuItem = UIMenuItem(title: actionType.title,
                                      action: actionType.action)
            menuItems.append(menuItem)
        }
        
        UIMenuController.shared.menuItems = menuItems
        UIMenuController.shared.showMenu(from: self, rect: self.bounds)
    }
    
    func hideMenu() {
        resignFirstResponder()
        UIMenuController.shared.menuItems = nil
        UIMenuController.shared.hideMenu()
    }
    
    private func hideMenu(with completion: (() -> Void)?){
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        hideMenu()
        CATransaction.commit()
    }
    
    @objc func handleEdit(_ sender: AnyObject) {
        hideMenu {
            if let delegate = self.delegate as? TPCollectionCellDelegate {
                delegate.collectionCell(self, perfomMenuAction: .edit)
            }
        }
    }
    
    @objc func handleDelete(_ sender: AnyObject) {
        hideMenu {
            if let delegate = self.delegate as? TPCollectionCellDelegate {
                delegate.collectionCell(self, perfomMenuAction: .delete)
            }
        }
    }
}


