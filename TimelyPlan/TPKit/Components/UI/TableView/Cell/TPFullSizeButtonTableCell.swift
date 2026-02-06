//
//  TPFullSizeButtonTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/29.
//

import Foundation
import UIKit

class TPFullSizeButtonTableCellItem: TPBaseTableCellItem {

    /// 点击按钮
    var didClickButton: ((UIButton) -> Void)?
    
    /// 按钮标题
    var buttonTitle: String?
    
    /// 按钮图标名称
    var buttonImageName: String?
    
    /// 图片颜色
    var buttonImageColor: UIColor? = .label
    
    /// 点击按钮缩放因子
    var preferredTappedScale: CGFloat = 1.0
    
    /// 图片固定尺寸
    var buttonFixedImageSize: CGSize?
    
    /// 正常标题色
    var buttonNormalTitleColor: UIColor? = .label
    
    /// 选中标题颜色
    var buttonSelectedTitleColor: UIColor?
    
    /// 按钮内间距
    var buttonPadding: UIEdgeInsets = .zero
    
    var buttonNormalBackgroundColor: UIColor = .clear
    
    /// 按钮图片位置
    var buttonSelectedBackgroundColor: UIColor = .clear
    
    /// 圆角半径
    var buttonCornerRadius: CGFloat = 0.0
    
    override init() {
        super.init()
        self.registerClass = TPFullSizeButtonTableCell.self
    }
}

class TPFullSizeButtonTableCell: TPBaseTableCell {

    override var cellItem: TPBaseTableCellItem? {
        didSet {
            updateButtonTitle(animated: false)
        }
    }
    
    override var isDisabled: Bool {
        didSet {
            button.isEnabled = !isDisabled
        }
    }
    
    private(set) lazy var button: TPDefaultButton = {
        let button = TPDefaultButton()
        button.hitTestEdgeInsets = UIEdgeInsets(value: -15.0)
        button.titleConfig.font = BOLD_SYSTEM_FONT
        button.titleConfig.textAlignment = .center
        button.addTarget(self, action: #selector(didClickButton(_:)), for: .touchUpInside)
        return button
    }()

    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(button)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = contentView.layoutFrame()
    }
    
    @objc func didClickButton(_ button: UIButton){
        TPImpactFeedback.impactWithSoftStyle()
        
        /// 取消当前第一响应
        UIResponder.resignCurrentFirstResponder()
        
        /// 点击回调
        if let cellItem = cellItem as? TPFullSizeButtonTableCellItem {
            cellItem.didClickButton?(button)
        }
    }
    
    public func updateButtonTitle(animated: Bool) {
        self.selectionStyle = cellItem?.selectionStyle ?? .default
        guard let cellItem = cellItem as? TPFullSizeButtonTableCellItem else {
            return
        }
    
        button.title = cellItem.buttonTitle
        button.padding = cellItem.buttonPadding
        button.imageConfig.color = cellItem.buttonImageColor
        button.titleConfig.textColor = cellItem.buttonNormalTitleColor
        button.titleConfig.selectedTextColor = cellItem.buttonSelectedTitleColor
        button.normalBackgroundColor = cellItem.buttonNormalBackgroundColor
        button.selectedBackgroundColor = cellItem.buttonSelectedBackgroundColor
        button.cornerRadius = cellItem.buttonCornerRadius
        if let imageName = cellItem.buttonImageName {
            button.image = resGetImage(imageName)
        } else {
            button.image = nil
        }
        
        if animated {
            animateLayout(withDuration: 0.2)
        } else {
            setNeedsLayout()
        }
    }
}

