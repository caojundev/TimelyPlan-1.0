//
//  TPBaseTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/27.
//

import Foundation
import UIKit

class TPBaseTableCellItem: NSObject {
    
    /// 唯一标识
    var identifier: String = UUID().uuidString
    
    /// 单元格注册类
    var registerClass: UITableViewCell.Type = TPBaseTableCell.self
    
    /// 整数标签
    var tag: Int = 0

    /// 深度
    var depth: Int = 0
    
    /// 是否选中
    var isChecked: Bool = false
    
    /// 是否禁用
    var isDisabled: Bool = false
    
    /// 单元格选中样
    var selectionStyle: UITableViewCell.SelectionStyle = .default

    /// 单元格样式
    var style: TPTableCellStyle?
    
    /// 单元格条目更新方法
    var updater: (() -> Void)?
    
    /// 选中该单元格回调
    var didSelectHandler: (() -> Void)?
    
    /// 是否自适应尺寸
    var autoResizable: Bool = false
    
    /// 配件类型
    var accessoryType: UITableViewCell.AccessoryType = .none
    
    /// 左侧视图尺寸
    var leftViewSize: CGSize = .zero
    
    /// 左侧视图外间距
    var leftViewMargins: UIEdgeInsets = .zero
    
    /// 右侧视图尺寸
    var rightViewSize: CGSize = .zero
    
    /// 右侧视图外间距
    var rightViewMargins: UIEdgeInsets = .zero
    
    /// 单元格宽度
    var cellWidth: CGFloat?
    
    /// 内容内间距
    var contentPadding = TableCellLayout.withoutAccessoryContentPadding
    
    /// 单元格内间距
    var cellPadding: UIEdgeInsets {
        let layout = getLayout()
        return layout.cellPadding
    }
    
    ///
    var height: CGFloat {
        get {
            let layout = getLayout()
            return layout.height
        }
        
        set {
            _layout.height = newValue
        }
    }
    
    /// 最小高度（自动尺寸时有效）
    var minimumHeight: CGFloat = 0.0
    
    /// 最大高度
    var maximumHeight: CGFloat = .greatestFiniteMagnitude
        
    /// 单元格布局对象
    private var _layout = TPBaseTableCellLayout()
    
    convenience init(registerClass: UITableViewCell.Type) {
        self.init()
        self.registerClass = registerClass
    }
    
    convenience init(accessoryType: UITableViewCell.AccessoryType) {
        self.init()
        self.accessoryType = accessoryType
    }
    
    convenience init(autoResizable: Bool) {
        self.init()
        self.autoResizable = autoResizable
    }
    
    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? TPBaseTableCellItem else {
            return false
        }

        return identifier == object.identifier
    }
    
    // MARK: - Getters & Setters
    func getLayout() -> TPBaseTableCellLayout {
        _layout.cellWidth = cellWidth
        _layout.autoResizable = autoResizable
        _layout.minimumHeight = minimumHeight
        _layout.maximumHeight = maximumHeight
        _layout.accessoryType = accessoryType
        _layout.contentPadding = contentPadding
        _layout.leftViewSize = leftViewSize
        _layout.leftViewMargins = leftViewMargins
        _layout.rightViewSize = rightViewSize
        _layout.rightViewMargins = rightViewMargins
        return _layout
    }
    
    func setLayout(_ layout: TPBaseTableCellLayout) {
        _layout = layout
    }
}

class TPBaseTableCell: UITableViewCell, Checkable, FocusAnimatable {
    
    /// 单元格代理对象
    weak var delegate: AnyObject?
    
    /// 单元格条目
    var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem else {
                return
            }
    
            self.selectionStyle = cellItem.selectionStyle
            self.accessoryType = cellItem.accessoryType
            depth = cellItem.depth
            isDisabled = cellItem.isDisabled
            padding = cellItem.cellPadding
            contentPadding = cellItem.contentPadding
            leftViewSize = cellItem.leftViewSize
            leftViewMargins = cellItem.leftViewMargins
            rightViewSize = cellItem.rightViewSize
            rightViewMargins = cellItem.rightViewMargins
            setNeedsLayout()
        }
    }
    
    /// 左侧视图
    var leftView: UIView? {
        didSet {
            if leftView !== oldValue {
                oldValue?.removeFromSuperview()
            }
            
            if let leftView = leftView {
                contentView.addSubview(leftView)
            }
            
            setNeedsLayout()
        }
    }
 
    /// 左侧视图尺寸
    var leftViewSize: CGSize = .zero
    
    /// 左侧视图外间距
    var leftViewMargins: UIEdgeInsets = .zero
    
    /// 右侧视图
    var rightView: UIView? {
        didSet {
            if rightView !== oldValue {
                oldValue?.removeFromSuperview()
            }
            
            if let rightView = rightView {
                contentView.addSubview(rightView)
            }
            
            setNeedsLayout()
        }
    }
 
    /// 右侧视图尺寸
    var rightViewSize: CGSize = .zero
    
    /// 右侧视图外间距
    var rightViewMargins: UIEdgeInsets = .zero
    
    /// 深度
    var depth: Int = 0
    
    /// 单位深度对应的宽度
    var depthWidth: CGFloat = 25.0
    
    /// 是否禁用
    var isDisabled: Bool = false {
        didSet {
            contentView.alpha = isDisabled ? disabledContentAlpha : 1.0
            contentView.isUserInteractionEnabled = !isDisabled
        }
    }
    
    var isChecked: Bool {
        get {
            return _isChecked
        }
        
        set {
            setChecked(newValue, animated: false)
        }
    }
    
    var contentPadding: UIEdgeInsets {
        get {
            return contentView.padding
        }
        
        set {
            contentView.padding = newValue
        }
    }
    
    /// 单元格样式
    var style: TPTableCellStyle? {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 禁用内容透明值
    let disabledContentAlpha = 0.2

    /// 默认内容间距
    let defaultContentPadding = UIEdgeInsets(horizontal: 16.0)
    
    /// 默认聚焦内间距
    let defaultFocusPadding = UIEdgeInsets(horizontal: 2.0, vertical: 2.0)
    
    /// 默认聚焦圆角半径
    let defaultFocusCornerRadius: CGFloat = 8.0
    
    /// 默认聚焦线条宽度
    let defaultFocusLineWidth: CGFloat = 2.5
    
    fileprivate var _isChecked: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.backgroundView = UIView()
        self.selectedBackgroundView = UIView()
        self.multipleSelectionBackgroundView = UIView()
        self.contentView.padding = defaultContentPadding
        self.setupContentSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutContentView()
        layoutLeftView()
        layoutRightView()
        updateCellStyle()
    }
    
    /// 布局内容视图
    func layoutContentView() {
        let layoutFrame = layoutFrame()
        let depthLength = CGFloat(depth) * depthWidth
        contentView.width = layoutFrame.width - depthLength
        contentView.height = bounds.height
        contentView.left = layoutFrame.minX + depthLength
    }
    
    /// 布局左视图
    func layoutLeftView() {
        guard let leftView = leftView else {
            return
        }

        let layoutFrame = contentView.layoutFrame()
        leftView.size = leftViewSize
        leftView.left = layoutFrame.minX + leftViewMargins.left
        leftView.centerY = layoutFrame.midY
    }
    
    /// 布局右视图
    func layoutRightView() {
        guard let rightView = rightView else {
            return
        }
        
        let layoutFrame = contentView.layoutFrame()
        rightView.size = rightViewSize
        rightView.right = layoutFrame.maxX - rightViewMargins.right
        rightView.centerY = layoutFrame.midY
    }
    
    /// 当前可用的布局区域
    func availableLayoutFrame() -> CGRect {
        let insets = UIEdgeInsets(left: leftViewSize.width + leftViewMargins.horizontalLength,
                                  right: rightViewSize.width + rightViewMargins.horizontalLength)
        return contentView.layoutFrame().inset(by: insets)
    }
    
    // MARK: - 初始化内容子视图
    func setupContentSubviews() {
        
    }
    
    
    // MARK: - Display
    func willDisplay() {
        
    }
    
    func didEndDisplaying() {
        
    }
    
    // MARK: - Update Style
    func updateCellStyle() {
        tintColor = style?.tintColor ?? .primary
        backgroundView?.backgroundColor = style?.backgroundColor
        selectedBackgroundView?.backgroundColor = style?.selectedBackgroundColor
        multipleSelectionBackgroundView?.backgroundColor = style?.multipleSelectionBackgroundColor
    }
    
    // MARK: - Checkable
    func setChecked(_ checked: Bool, animated: Bool) {
        _isChecked = checked
    }

    // MARK: - FocusAnimatable
    var focusPadding: UIEdgeInsets {
        return defaultFocusPadding
    }
    
    var focusCornerRadius: CGFloat {
        return defaultFocusCornerRadius
    }
    
    /// 线条宽度
    var focusLineWidth: CGFloat {
        return defaultFocusLineWidth
    }
    
    /// 线条颜色
    var focusLineColor: UIColor {
        return .primary
    }
    
}
