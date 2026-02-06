//
//  FlipClockElementHalfView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/2.
//

import Foundation
import UIKit

class FlipClockElementHalfView: UIView {
    
    enum Style {
        case top /// 上部
        case bottom /// 下部
    }

    /// 样式
    let style: Style
    
    /// 圆角半径
    var cornerRadius: CGFloat = 24.0 {
        didSet { setNeedsLayout() }
    }
    
    /// 中线空白间距
    var spacing: CGFloat = 8.0 {
        didSet { setNeedsLayout() }
    }
    
    /// 阴影半径
    var shadowRadius: CGFloat = 16.0 {
        didSet { setNeedsLayout() }
    }
    
    var shadowColor: UIColor = Color(0x000000, 0.6)
    
    /// 文本字体
    var font: UIFont? = .robotoMonoBoldFont(size: 300.0) {
        didSet {
            textLabel.font = font
        }
    }
    
    /// 文本颜色
    var textColor: UIColor? = Color(0xFFFFFF, 0.8) {
        didSet {
            textLabel.textColor = textColor
        }
    }
    
    /// 背景颜色
    var backColor: UIColor? = Color(0x222222) {
        didSet {
            contentView.backgroundColor = backColor
        }
    }

    /// 文本
    var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
    /// 内容间距
    var contentPadding: UIEdgeInsets = .zero
    
    /// 标签
    private let textLabel = UILabel()
    
    /// 内容视图
    private let contentView = UIView()
    
    /// 背景图层
    private var contentMaskLayer = CAShapeLayer()
    
    /// 阴影图层
    private var shadowLayer = CAShapeLayer()
    private var shadowMaskLayer = CAShapeLayer()
    
    convenience init(style: Style) {
        self.init(frame: .zero, style: style)
    }
    
    init(frame: CGRect, style: Style) {
        self.style = style
        super.init(frame: frame)
        self.clipsToBounds = false
        
        shadowLayer.mask = shadowMaskLayer
        layer.addSublayer(shadowLayer)
        
        contentView.backgroundColor = backColor
        contentView.layer.mask = contentMaskLayer
        addSubview(contentView)
    
        textLabel.textColor = textColor
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.textAlignment = .center
        contentView.addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        contentView.frame = bounds
        textLabel.frame = bounds.inset(by: contentPadding)
        
        contentMaskLayer.frame = bounds
        contentMaskLayer.path = contentMaskLayerPath().cgPath

        shadowLayer.frame = bounds
        shadowLayer.setBorderShadow(color: shadowColor,
                                    offset: .zero,
                                    radius: shadowRadius)
        shadowMaskLayer.path = shadowMaskLayerPath().cgPath
        CATransaction.commit()
    }
    
    private func contentMaskLayerPath() -> UIBezierPath {
        let height = halfHeight - spacing / 2.0
        let roundedRect: CGRect
        let roundingCorners: UIRectCorner
        if style == .top {
            roundingCorners = [.topLeft, .topRight]
            roundedRect = CGRect(x: 0, y: 0, width: width, height: height)
        } else {
            roundingCorners = [.bottomLeft, .bottomRight]
            roundedRect = CGRect(x: 0, y: halfHeight + spacing / 2.0, width: width, height: height)
        }
        
        let path = UIBezierPath(roundedRect: roundedRect,
                                byRoundingCorners: roundingCorners,
                                cornerRadii: CGSize(cornerRadius, cornerRadius))
        return path
    }
    
    private func shadowMaskLayerPath() -> UIBezierPath {
         let radius = shadowRadius
         let shadowRadius = 2 * radius
         let width = width + 2 * shadowRadius
         let height = halfHeight + shadowRadius
         let rect: CGRect
         if style == .top {
             rect = CGRect(x: -shadowRadius,
                           y: -shadowRadius,
                           width: width,
                           height: height)
         } else {
             rect = CGRect(x: -shadowRadius,
                           y: halfHeight,
                           width: width,
                           height: height)
         }
         
         return UIBezierPath(rect: rect)
     }
}

