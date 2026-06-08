//
//  TodoTaskMoveSectionCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/5.
//

import Foundation
import UIKit

class TodoTaskMoveSectionCell: TPImageInfoTableCell {
    
    var section: TodoSection? {
        didSet {
            title = section?.name ?? resGetString("Untitled Section")
            let listDepth = section?.list?.depth ?? 0
            depth = listDepth + 1
            depthLineLayer.indentationLevel = self.depth
            setNeedsLayout()
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
    
    /// 缩进分割线图层
    private(set) lazy var depthLineLayer: TodoSectionBranchLayer = {
        let layer = TodoSectionBranchLayer()
        layer.indentationWidth = depthWidth
        layer.lineWidth = 2.0
        layer.strokeColor = UIColor.lightGray.cgColor
        return layer
    }()
    
    /// 对勾图标
    private lazy var checkmarkView: UIImageView = {
        let view = UIImageView()
        view.size = .mini
        view.image = resGetImage("checkmark_24")
        view.updateImage(withColor: .primary)
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentPadding = UIEdgeInsets(left: 24.0, right: 16.0)
        layer.addSublayer(depthLineLayer)
        imageConfig.shouldRenderImageWithColor = true
        imageContent = .init(imageName: "todo_section_24")
        imageConfig.margins = UIEdgeInsets(right: 4.0)
        rightView = checkmarkView
        rightViewSize = .mini
        isChecked = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        depthLineLayer.frame = CGRect(x: 0.0,
                                      y: 0.0,
                                      width: contentView.left,
                                      height: bounds.height)
        depthLineLayer.indentationWidth = depthWidth
        CATransaction.commit()
    }
    
    override func updateCellStyle() {
        super.updateCellStyle()
        let imageConfig = imageConfig
        let titleConfig = titleConfig
        if isChecked {
            titleConfig.textColor = .primary
        } else {
            titleConfig.textColor = resGetColor(.title)
        }
        
        imageConfig.color = titleConfig.textColor
        imageInfoView.imageConfig = imageConfig
        imageInfoView.titleConfig = titleConfig
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkmarkView.isHidden = !checked
        updateCellStyle()
    }
}
