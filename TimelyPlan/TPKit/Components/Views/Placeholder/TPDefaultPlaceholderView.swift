//
//  TPDefaultPlaceholderView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/11.
//

import Foundation
import UIKit

class TPDefaultPlaceholderView: UIView {
    
    // 添加点击回调闭包
    var didTapHandler: (() -> Void)?

    let kMaxContentWidth: CGFloat = 400.0
    
    var titleTopMargin: CGFloat = 15.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var subtitleTopMargin: CGFloat = 10.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var isBorderHidden: Bool = true {
        didSet {
            if isBorderHidden == oldValue {
                return
            }
            
            setupBorderLayer()
        }
    }
    
    func setupBorderLayer() {
        if isBorderHidden {
            borderLayer?.removeFromSuperlayer()
            borderLayer = nil
        } else {
            borderLayer = TPBorderLayer()
            borderLayer?.lineColor = borderLineColor
            layer.addSublayer(borderLayer!)
        }
    }
    
    var borderLayer: TPBorderLayer?
    
    /// 边框线条颜色
    var borderLineColor: UIColor = Color(0x888888, 0.6)
    
    /// 图片
    var imageColor: UIColor? {
        didSet {
            imageView.image = image
            setNeedsLayout()
        }
    }
    
    var imageSize: CGSize? {
        didSet {
            setNeedsLayout()
        }
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image
            setNeedsLayout()
        }
    }
    
    private(set) lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = BOLD_BODY_FONT
        label.alpha = 0.8
        label.textAlignment = .center
        return label
    }()
    
    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        label.textAlignment = .center
        label.textColor = .separator
        return label
    }()
    
    var title: String? {
        get { return titleLabel.text }
        set {
            titleLabel.text = newValue
            setNeedsLayout()
        }
    }
    
    var titleFont: UIFont {
        get { return titleLabel.font }
        set { titleLabel.font = newValue }
    }
    
    var titleColor: UIColor {
        get { return titleLabel.textColor }
        set { titleLabel.textColor = newValue }
    }
    
    var detail: String? {
        get { return detailLabel.text }
        set {
            detailLabel.text = newValue
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(detailLabel)
        setupBorderLayer()
        
        // 添加单击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        borderLayer?.frame = layoutFrame
        var contentWidth = layoutFrame.width
        if contentWidth > kMaxContentWidth {
            contentWidth = kMaxContentWidth
        }
        
        if let imageSize = imageSize {
            imageView.size = imageSize
        } else {
            imageView.sizeToFit()
        }
        
        imageView.updateContentMode()
        if let imageColor = imageColor {
            imageView.updateImage(withColor: imageColor)
        }
        
        titleLabel.width = contentWidth
        titleLabel.sizeToFit()
        
        detailLabel.width = contentWidth
        detailLabel.sizeToFit()
        
        let contentHeight = imageView.height + titleLabel.height + detailLabel.height + titleTopMargin + subtitleTopMargin
        let top = (layoutFrame.height - contentHeight) / 2.0
        
        imageView.top = layoutFrame.minY + top
        imageView.alignHorizontalCenter()
        
        titleLabel.top = imageView.bottom + titleTopMargin
        titleLabel.alignHorizontalCenter()
        
        detailLabel.top = titleLabel.bottom + subtitleTopMargin
        detailLabel.alignHorizontalCenter()
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        didTapHandler?()
    }
}


