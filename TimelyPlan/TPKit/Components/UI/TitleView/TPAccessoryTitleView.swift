//
//  TPAccessoryTitleView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/12.
//

import Foundation
import UIKit

/// 位置
enum TPAccessoryPosition: Int {
    case top
    case left
    case bottom
    case right
}

class TPAccessoryTitleView: UIView {
 
    /// 对齐方式
    enum AccessoryAlignment: Int {
        case left
        case center
        case right
    }

    var isHighlighted: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }

    var isSelected: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    var accessoryPosition: TPAccessoryPosition = .left {
        didSet {
            setNeedsLayout()
        }
    }
    
    var accessoryMargins: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    var accessorySize: CGSize = .mini {
        didSet {
            setNeedsLayout()
        }
    }

    var accessoryAlignment: AccessoryAlignment = .center {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 左配件视图视图
    var accessoryView: UIView? {
        didSet {
            if accessoryView !== oldValue {
                oldValue?.removeFromSuperview()
            }
            
            if let accessoryView = accessoryView {
                addSubview(accessoryView)
            }
            
            setNeedsLayout()
        }
    }
    
    var title: TextRepresentable? {
        get {
            return titleContent?.value
        }

        set {
            titleContent = .withText(newValue)
        }
    }
    
    var titleContent: TPLabelContent? {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 标题配置
    var titleConfig: TPLabelConfig = .titleConfig {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 文本标签
    private(set) lazy var titleLabel: TPLabel = {
        let label = TPLabel()
        label.textAlignment = .center
        label.font = BOLD_SYSTEM_FONT
        label.numberOfLines = 1
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func setupSubviews() {
        addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateContent()
        
        let layoutFrame = self.layoutFrame()
        let accessorySize = fitAccessorySize()
        let accessoryMargins = fitAccessoryMargins()
        accessoryView?.size = accessorySize
        switch accessoryPosition {
        case .top:
            accessoryView?.top = layoutFrame.minY + accessoryMargins.top
            titleLabel.width = layoutFrame.width
            let titleHeight = layoutFrame.height - accessorySize.height - accessoryMargins.verticalLength
            titleLabel.height = max(0.0, titleHeight)
            titleLabel.top = layoutFrame.minY + accessoryMargins.verticalLength + accessorySize.height
            titleLabel.left = layoutFrame.minX
        case .left:
            accessoryView?.left = layoutFrame.minX + accessoryMargins.left
            accessoryView?.centerY = layoutFrame.midY
            let titleWidth = layoutFrame.width - accessorySize.width - accessoryMargins.horizontalLength
            titleLabel.width = max(0.0, titleWidth)
            titleLabel.height = layoutFrame.height
            titleLabel.top = layoutFrame.minY
            titleLabel.left = layoutFrame.minX + accessoryMargins.horizontalLength + accessorySize.width
        case .bottom:
            let titleHeight = layoutFrame.height - accessorySize.height - accessoryMargins.verticalLength
            titleLabel.width = layoutFrame.width
            titleLabel.height = max(0.0, titleHeight)
            titleLabel.top = layoutFrame.minY
            accessoryView?.top = titleLabel.bottom + accessoryMargins.top
       case .right:
            let titleWidth = layoutFrame.width - accessorySize.width - accessoryMargins.horizontalLength
            titleLabel.width = max(0.0, titleWidth)
            titleLabel.height = layoutFrame.height
            titleLabel.top = layoutFrame.minY
            titleLabel.left = layoutFrame.minX
            accessoryView?.left = titleLabel.right + accessoryMargins.left
            accessoryView?.centerY = layoutFrame.midY
        }
        
        if accessoryPosition == .top || accessoryPosition == .bottom {
            switch accessoryAlignment {
            case .left:
                accessoryView?.left = layoutFrame.minX
            case .center:
                accessoryView?.centerX = layoutFrame.midX
            case .right:
                accessoryView?.right = layoutFrame.maxX
            }
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let accessorySize = fitAccessorySize()
        let accessoryMargins = fitAccessoryMargins()
        var totalSize: CGSize = .zero
        let layout = TPLabelLayout(content: titleContent, config: titleConfig)
        switch accessoryPosition {
        case .top, .bottom:
            let labelSize = layout.boundingSize(with: .greatestFiniteMagnitude)
            totalSize.width = max(accessorySize.width, labelSize.width) + padding.horizontalLength
            var height = accessorySize.height + labelSize.height
            if accessorySize.height > 0 && labelSize.height > 0 {
                height += accessoryMargins.verticalLength
            }
            
            totalSize.height = height
        case .left, .right:
            let labelSize = layout.boundingSize(with: .greatestFiniteMagnitude)
            var width = accessorySize.width + labelSize.width
            if accessorySize.width > 0 && labelSize.width > 0 {
                width += accessoryMargins.horizontalLength
            }
        
            totalSize.width = width + padding.horizontalLength
            totalSize.height = max(accessorySize.height, labelSize.height) + padding.verticalLength
        }
        
        return totalSize
    }
    
    func fitAccessorySize() -> CGSize {
        return accessorySize
    }
    
    func fitAccessoryMargins() -> UIEdgeInsets {
        return accessoryMargins
    }
    
    // MARK: - 更新标题
    func updateContent() {
        titleLabel.isHighlighted = isHighlighted
        titleLabel.isSelected = isSelected
        titleLabel.updateConfig(titleConfig)
        titleLabel.updateContent(titleContent)
    }
    
}
