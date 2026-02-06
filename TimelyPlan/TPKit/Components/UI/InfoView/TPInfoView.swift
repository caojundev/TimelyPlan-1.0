//
//  TPInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/9.
//

import Foundation
import UIKit

class TPInfoView: UIView {
    
    var title: TextRepresentable? {
        get {
            return titleContent?.value
        }
        
        set {
            titleContent = .withText(newValue)
        }
    }
    
    var subtitle: TextRepresentable? {
        get {
            return subtitleContent?.value
        }
        
        set {
            subtitleContent = .withText(newValue)
        }
    }
    
    /// 标题内容
    var titleContent: TPLabelContent? {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 副标题内容
    var subtitleContent: TPLabelContent? {
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
    
    /// 副标题配置
    var subtitleConfig: TPLabelConfig = .subtitleConfig {
        didSet {
            setNeedsLayout()
        }
    }
    
    var subtitleTopMargin: CGFloat = 5.0 {
        didSet {
            if subtitleTopMargin != oldValue {
                setNeedsLayout()
            }
        }
    }

    /// 左配件视图外间距
    var leftAccessoryMargins: UIEdgeInsets = .zero {
        didSet {
            if leftAccessoryMargins != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 左配件视图尺寸
    var leftAccessorySize: CGSize = .zero {
        didSet {
            if leftAccessorySize != oldValue {
                setNeedsLayout()
            }
        }
    }

    /// 左配件视图视图
    var leftAccessoryView: UIView? {
        didSet {
            if leftAccessoryView !== oldValue {
                oldValue?.removeFromSuperview()
            }
            
            if let leftAccessoryView = leftAccessoryView {
                addSubview(leftAccessoryView)
            }
            
            setNeedsLayout()
        }
    }
    
    /// 右配件视图外间距
    var rightAccessoryMargins: UIEdgeInsets = .zero {
        didSet {
            if rightAccessoryMargins != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 右配件视图尺寸
    var rightAccessorySize: CGSize = .zero {
        didSet {
            if rightAccessorySize != oldValue {
                setNeedsLayout()
            }
        }
    }

    /// 右配件视图视图
    var rightAccessoryView: UIView? {
        didSet {
            if rightAccessoryView !== oldValue {
                oldValue?.removeFromSuperview()
            }
            
            if let rightAccessoryView = rightAccessoryView {
                addSubview(rightAccessoryView)
            }
            
            setNeedsLayout()
        }
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
    
    /// 标题标签
    private lazy var titleLabel: TPLabel = {
        let label = TPLabel()
        return label
    }()
    
    /// 副标题标签
    private lazy var subtitleLabel: TPLabel = {
        let label = TPLabel()
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
        addSubview(subtitleLabel)
    }

    private func applyConfig() {
        titleLabel.isHighlighted = isHighlighted
        titleLabel.isSelected = isSelected
        titleLabel.updateConfig(titleConfig)
    
        subtitleLabel.isHighlighted = isHighlighted
        subtitleLabel.isSelected = isSelected
        subtitleLabel.updateConfig(subtitleConfig)
    }
    
    private func updateContent() {
        titleLabel.updateContent(titleContent)
        subtitleLabel.updateContent(subtitleContent)
    }

    private func updateInfo() {
        applyConfig()
        updateContent()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateInfo()

        let labelLayoutFrame = labelLayoutFrame()
        let limitSize = CGSize(width: labelLayoutFrame.width, height: CGFloat.greatestFiniteMagnitude)
        var titleSize = titleLabel.sizeThatFits(limitSize)
        titleSize.width = labelLayoutFrame.width
        
        var subtitleSize = subtitleLabel.sizeThatFits(limitSize)
        subtitleSize.width = labelLayoutFrame.width
        
        var labelHeight = titleSize.height + subtitleSize.height
        if subtitleSize.height > 0 {
            labelHeight += subtitleTopMargin
        }
        
        var top = (labelLayoutFrame.height - labelHeight) / 2.0
        top = top < 0 ? 0 : top
        top += labelLayoutFrame.minY
        
        titleLabel.size = titleSize
        titleLabel.top = top
        titleLabel.left = labelLayoutFrame.minX
        
        subtitleLabel.size = subtitleSize
        subtitleLabel.top = titleLabel.bottom + subtitleTopMargin
        subtitleLabel.left = labelLayoutFrame.minX
        layoutAccessoryView()
    }

    func layoutAccessoryView() {
        let layoutFrame = layoutFrame()
        if let leftAccessoryView = leftAccessoryView {
            leftAccessoryView.size = leftAccessorySize
            leftAccessoryView.left = layoutFrame.minX + leftAccessoryMargins.left
            leftAccessoryView.centerY = layoutFrame.midY
        }
        
        if let rightAccessoryView = rightAccessoryView {
            rightAccessoryView.size = rightAccessorySize
            rightAccessoryView.right = layoutFrame.maxX - rightAccessoryMargins.right
            rightAccessoryView.centerY = layoutFrame.midY
        }
    }

    /// 标签布局
    func labelLayoutFrame() -> CGRect {
        let layoutFrame = layoutFrame()
        let left = layoutFrame.minX + leftAccessorySize.width + leftAccessoryMargins.horizontalLength
        let right = layoutFrame.maxX - rightAccessorySize.width - rightAccessoryMargins.horizontalLength
        let width = right - left
        if width > 0.0 {
            return CGRect(x: left, y: layoutFrame.minY, width: width, height: layoutFrame.height)
        }
        
        return .zero
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = TPInfoViewLayout()
        layout.titleContent = titleContent
        layout.subtitleContent = subtitleContent
        layout.titleConfig = titleConfig
        layout.subtitleConfig = subtitleConfig
        layout.subtitleTopMargin = subtitleTopMargin
        layout.padding = padding
        layout.leftAccessorySize = leftAccessorySize
        layout.leftAccessoryMargins = leftAccessoryMargins
        layout.rightAccessorySize = rightAccessorySize
        layout.rightAccessoryMargins = rightAccessoryMargins
        return layout.sizeThatFits(.unlimited)
    }
}

class TPInfoViewLayout {

    /// 标题内容
    var titleContent: TPLabelContent?
    
    /// 标题配置
    var titleConfig: TPLabelConfig = .titleConfig
    
    /// 副标题内容
    var subtitleContent: TPLabelContent?
    
    /// 副标题配置
    var subtitleConfig: TPLabelConfig = .subtitleConfig

    /// 副标题与标题间距
    var subtitleTopMargin: CGFloat = 5.0

    /// 内间距
    var padding: UIEdgeInsets = .zero
    
    /// 左配件视图
    var leftAccessoryMargins: UIEdgeInsets = .zero

    /// 左配件视图尺寸
    var leftAccessorySize: CGSize = .zero
    
    /// 右配件视图
    var rightAccessoryMargins: UIEdgeInsets = .zero

    /// 右配件视图尺寸
    var rightAccessorySize: CGSize = .zero

    func boundingSize(with constraintWidth: CGFloat) -> CGSize {
        let leftAccessoryLength = leftAccessorySize.width + leftAccessoryMargins.horizontalLength
        let rightAccessoryLength = rightAccessorySize.width + rightAccessoryMargins.horizontalLength
        let maxWidth = constraintWidth - leftAccessoryLength - rightAccessoryLength - padding.horizontalLength
        
        let titleLayout = TPLabelLayout(content: titleContent, config: titleConfig)
        let titleSize = titleLayout.boundingSize(with: maxWidth)
        
        let subtitleLayout = TPLabelLayout(content: subtitleContent, config: subtitleConfig)
        let subtitleSize = subtitleLayout.boundingSize(with: maxWidth)
        
        let labelWidth = max(titleSize.width, subtitleSize.width)
        var labelHeight = ceil(titleSize.height) + ceil(subtitleSize.height)
        if labelHeight > 0 {
            labelHeight += subtitleTopMargin /// 增加副标题顶部间距
        }
        
        let contentWidth = ceil(labelWidth) + padding.horizontalLength + leftAccessoryLength + rightAccessoryLength
        let contentHeight = ceil(labelHeight) + padding.verticalLength
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    func sizeThatFits(_ size: CGSize? = nil) -> CGSize {
        var constraintWidth: CGFloat = .greatestFiniteMagnitude
        if let size = size {
            constraintWidth = size.width
       }
           
        let boundingSize = boundingSize(with: constraintWidth)
        return boundingSize
    }
}


