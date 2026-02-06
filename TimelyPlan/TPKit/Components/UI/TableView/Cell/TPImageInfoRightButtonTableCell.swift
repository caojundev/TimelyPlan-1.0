//
//  TPImageInfoRightButtonTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/6.
//

import Foundation
import UIKit

class TPImageInfoRightButtonTableCellItem: TPImageInfoTableCellItem {
    
    /// 点击右侧按钮
    var didClickRightButton: ((UIButton) -> Void)?
    
    /// 按钮图标名称
    var rightButtonImageName: String?
    
    /// 图片颜色
    var rightButtonNormalImageColor: UIColor?
    
    var isRightButtonHidden: Bool = false
    
    /// 按钮是否可用
    var isRightButtonEnabled: Bool = true
    
    override init() {
        super.init()
        self.registerClass = TPImageInfoRightButtonTableCell.self
        self.rightViewMargins = .zero
        self.rightViewSize = .mini
    }
}

class TPImageInfoRightButtonTableCell: TPImageInfoTableCell {

    /// 点击右侧按钮回调
    var didClickRightButton: ((UIButton) -> Void)?

    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPImageInfoRightButtonTableCellItem else {
                return
            }
            
            if let imageName = cellItem.rightButtonImageName {
                rightButton.image = resGetImage(imageName)
            } else {
                rightButton.image = nil
            }
            
            rightButton.imageConfig.color = cellItem.rightButtonNormalImageColor
            rightButton.isEnabled = cellItem.isRightButtonEnabled
            rightButton.isHidden = cellItem.isRightButtonHidden
            didClickRightButton = cellItem.didClickRightButton
        }
    }
    
    /// 展开按钮
    private(set) lazy var rightButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.imageConfig.margins = .zero
        button.padding = .zero
        button.hitTestEdgeInsets = UIEdgeInsets(value: -10.0)
        button.imageConfig.color = resGetColor(.title)
        button.normalBackgroundColor = .clear
        button.selectedBackgroundColor = .clear
        button.addTarget(self, action: #selector(clickRightButton(_:)), for: .touchUpInside)
        return button
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.rightView = rightButton
        self.rightViewSize = .mini
    }
    
    override func layoutRightView() {
        super.layoutRightView()
        rightButton.imageConfig.size = rightViewSize
    }
    
    // MARK: - Event Response
    
    @objc func clickRightButton(_ button: UIButton) {
        didClickRightButton?(rightButton)
    }
}
