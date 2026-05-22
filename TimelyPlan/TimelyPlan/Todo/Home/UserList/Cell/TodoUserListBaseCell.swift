//
//  TodoUserListBaseCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/7.
//

import Foundation
import UIKit

class TodoUserListBaseCell: TPExpandDefaultInfoTableCell {

    /// 列表
    var list: TodoList? {
        didSet {
            self.updateListInfo()
        }
    }
    
    /// 深度绘制层级
    var depthLineLevels: [Int]? {
        get {
            return depthLineLayer.depthLineLevels
        }
        
        set {
            depthLineLayer.depthLineLevels = newValue
        }
    }

    /// 列表深度
    override var depth: Int {
        didSet {
            if depth < kTodoListMaxDepth {
                expandButton.isHidden = false
            } else {
                expandButton.isHidden = true
            }
            
            depthLineLayer.indentationLevel = depth
        }
    }

    var iconInfoTextValueView: TPIconInfoTextValueView {
        return infoView as! TPIconInfoTextValueView
    }

    /// 缩进分割线图层
    private(set) lazy var depthLineLayer: TodoListBranchLayer = {
        let layer = TodoListBranchLayer()
        layer.maxDepth = kTodoListMaxDepth
        layer.indentationWidth = depthWidth
        layer.lineWidth = 2.0
        layer.strokeColor = UIColor.lightGray.cgColor
        return layer
    }()

    override func setupInfoView() {
        self.infoView = TPIconInfoTextValueView()
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.padding = UIEdgeInsets(left: 12.0, right: 12.0)
        infoView.titleConfig.lineBreakMode = .byTruncatingMiddle
        infoView.subtitleConfig.font = UIFont.boldSystemFont(ofSize: 8.0)
        infoView.subtitleConfig.alpha = 0.6
        layer.addSublayer(depthLineLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        depthLineLayer.frame = CGRect(x: 0.0, y: 0.0, width: contentView.left, height: bounds.height)
        depthLineLayer.dx = expandButton.centerX - depthWidth
        depthLineLayer.indentationWidth = depthWidth
        CATransaction.commit()
    }
    
    override func isExpandButtonEnabled() -> Bool {
        let isEnabled = super.isExpandButtonEnabled()
        guard isEnabled else {
            return false
        }
        
        return list?.hasSubItem ?? false
    }
    
    func updateListInfo() {
        guard let list = list else {
            return
        }

        self.depth = list.depth
        self.infoView.title = list.name
        
        let iconConfig = TPIconAccessoryConfig()
        iconConfig.margins = .zero
        iconConfig.icon = list.icon
        iconConfig.foreColor = list.color
        self.iconInfoTextValueView.iconConfig = iconConfig
        
        self.updateExpanded(animated: false)
        self.updateExpandedButton()
        setNeedsLayout()
    }
}
