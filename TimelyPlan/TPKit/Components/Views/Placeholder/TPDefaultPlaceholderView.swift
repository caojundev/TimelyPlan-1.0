//
//  TPDefaultPlaceholderView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/11.
//

import Foundation
import UIKit

class TPDefaultPlaceholderView: UIView {

    let kItemMargin: CGFloat = 5.0  // 条目间距
    let kMaxContentWidth: CGFloat = 400.0

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
        
        let contentHeight = imageView.height + titleLabel.height + detailLabel.height + 2 * kItemMargin
        let top = (layoutFrame.height - contentHeight) / 2.0
        
        imageView.top = layoutFrame.minY + top
        imageView.alignHorizontalCenter()
        
        titleLabel.top = imageView.bottom + kItemMargin
        titleLabel.alignHorizontalCenter()
        
        detailLabel.top = titleLabel.bottom + kItemMargin
        detailLabel.alignHorizontalCenter()
    }
}


