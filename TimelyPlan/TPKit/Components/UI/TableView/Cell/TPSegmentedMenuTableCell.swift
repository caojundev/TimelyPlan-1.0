//
//  TPSegmentedMenuTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/30.
//

import Foundation
import UIKit

class TPSegmentedMenuTableCellItem: TPImageInfoTableCellItem {
    
    /// 菜单条目间距
    var menuMargin: CGFloat = 5.0
    
    /// 菜单内间距
    var menuPadding: UIEdgeInsets = UIEdgeInsets(value: 4.0)
    
    /// 菜单条目
    var menuItems: [TPSegmentedMenuItem] = []
    
    /// 选中菜单索引
    var selectedMenuTag: Int = 0

    /// 圆角半径
    var cornerRadius: CGFloat = 8.0
    
    /// 最小按钮宽度
    var minimumButtonWidth: CGFloat = 0.0
    
    /// 最大按钮宽度
    var maximumButtonWidth: CGFloat = .greatestFiniteMagnitude
    
    /// 背景颜色
    var backgroundColor: UIColor? = .clear

    /// 选中背景颜色
    var selectedBackgroundColor: UIColor? = .primary
    
    /// 按钮正常背景色
    var buttonNormalBackgroundColor: UIColor = .clear

    /// 选中菜单条目回调
    var didSelectMenuItem: ((TPSegmentedMenuItem) -> Void)?
    
    var segmentedSize: CGSize {
        get {
            return rightViewSize
        }
        
        set {
            rightViewSize = newValue
        }
    }
    
    /// 图片位置
    var imagePosition: TPAccessoryPosition = .left
    
    var segmentedTitleConfig: TPLabelConfig = .titleConfig
    
    var segmentedImageConfig: TPImageAccessoryConfig = .init()
    
    override init() {
        super.init()
        registerClass = TPSegmentedMenuTableCell.self
        selectionStyle = .none
        height = TPSegmentedMenuTableCell.defaultHeight
        segmentedSize = TPSegmentedMenuTableCell.defaultMenuSize
        backgroundColor = .tertiarySystemGroupedBackground
        segmentedTitleConfig.font = BOLD_SMALL_SYSTEM_FONT
        segmentedTitleConfig.textAlignment = .center
        segmentedTitleConfig.selectedTextColor = .white
        segmentedImageConfig.selectedColor = .white
    }
}

class TPSegmentedMenuTableCell: TPImageInfoTableCell {
    
    /// 默认高度
    static let defaultHeight = 55.0
    
    /// 默认菜单尺寸
    static let defaultMenuSize = CGSize(width: 120, height: 40)
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPSegmentedMenuTableCellItem else {
                return
            }
            
            menuView.margin = cellItem.menuMargin
            menuView.padding = cellItem.menuPadding
            menuView.menuItems = cellItem.menuItems
            menuView.cornerRadius = cellItem.cornerRadius
            menuView.minButtonWidth = cellItem.minimumButtonWidth
            menuView.maxButtonWidth = cellItem.maximumButtonWidth
            menuView.normalBackgroundColor = cellItem.backgroundColor
            menuView.selectedBackgroundColor = cellItem.selectedBackgroundColor
            menuView.buttonNormalBackgroundColor = cellItem.buttonNormalBackgroundColor
            menuView.imagePosition = cellItem.imagePosition
            menuView.titleConfig = cellItem.segmentedTitleConfig
            menuView.imageConfig = cellItem.segmentedImageConfig
            menuView.selectMenu(withTag: cellItem.selectedMenuTag, animated: false)
            setNeedsLayout()
        }
    }

    private(set) lazy var menuView: TPSegmentedMenuView = {
        let menuView = TPSegmentedMenuView()
        menuView.margin = 0.0
        menuView.didSelectMenuItem = { [weak self] menuItem in
            self?.didSelectMenuItem(menuItem)
        }
        
        return menuView
    }()
    
//    override func layoutSubviews() {
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        super.layoutSubviews()
//        CATransaction.commit()
//    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        setupSegmentedMenuView()
    }
    
    func setupSegmentedMenuView() {
        rightView = menuView
        rightViewSize = Self.defaultMenuSize
    }
    
    func didSelectMenuItem(_ menuItem: TPSegmentedMenuItem) {
        guard let cellItem = cellItem as? TPSegmentedMenuTableCellItem else {
            return
        }
        
        cellItem.selectedMenuTag = menuItem.tag
        cellItem.didSelectMenuItem?(menuItem)
    }
}
