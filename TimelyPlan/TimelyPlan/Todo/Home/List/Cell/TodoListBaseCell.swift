//
//  TodoListBaseCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/1.
//

import Foundation
import UIKit

class TodoListBaseCell: TPDefaultInfoTableCell {

    /// 列表
    var list: TodoList? {
        didSet {
            self.depth = list?.folder != nil ? 1 : 0
            self.title = list?.name
        
            let iconConfig = TPIconAccessoryConfig()
            iconConfig.margins = .zero
            iconConfig.icon = list?.icon
            iconConfig.foreColor = list?.color
            iconInfoTextValueView.iconConfig = iconConfig
            setNeedsLayout()
        }
    }

    /// 列表深度
    override var depth: Int {
        didSet {
            indentationGuideLayer.level = depth
        }
    }
    
    /// 缩进分割线图层
    private(set) lazy var indentationGuideLayer: TodoIndentationGuideLayer = {
        let layer = TodoIndentationGuideLayer()
        layer.indentationWidth = depthWidth
        layer.lineWidth = 2.0
        layer.strokeColor = Color(0x888888, 0.4).cgColor
        return layer
    }()
    
    lazy var iconInfoTextValueView: TPIconInfoTextValueView = {
        return TPIconInfoTextValueView()
    }()

    override func setupInfoView() {
        self.infoView = iconInfoTextValueView
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.padding = UIEdgeInsets(left: 20.0, right: 10.0)
        infoView.titleConfig.lineBreakMode = .byTruncatingMiddle
        layer.addSublayer(indentationGuideLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        indentationGuideLayer.frame = CGRect(x: 0.0, y: 0.0, width: contentView.left, height: bounds.height)
        indentationGuideLayer.indentationWidth = depthWidth
        indentationGuideLayer.dx = CGSize.mini.width / 2.0
        CATransaction.commit()
    }
}
