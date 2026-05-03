//
//  HabitReportRoundCornerHeaderFooterView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/17.
//

import Foundation
import UIKit

/// 位置枚举：表示视图是头部还是尾部
enum HabitReportSectionPosition {
    case header  // 头部 - 绘制左上和右上圆角
    case footer  // 尾部 - 绘制左下和右下圆角
}

class HabitReportRoundCornerHeaderFooterView: TPCollectionHeaderFooterView {
    /// 位置：头部或尾部
    var position: HabitReportSectionPosition = .header {
        didSet {
            if position != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 圆角半径
    var cornerRadius: CGFloat = 16.0
    
    var backgroundMargin: CGFloat = 16.0
    
    private(set) lazy var backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.layer.addSublayer(self.backgroundLayer)
        self.contentView.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBackgroundLayer()
    }
    
    /// 更新背景层的路径和颜色
    func updateBackgroundLayer() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let contentLayoutFrame = contentView.layoutFrame()
        let backgroundH = contentView.height - backgroundMargin
        
        // 根据位置确定圆角
        let roundingCorners: UIRectCorner
        let backgroundFrame: CGRect
        switch position {
        case .header:
            roundingCorners = [.topLeft, .topRight]
            backgroundFrame = CGRect(x: contentLayoutFrame.minX,
                                         y: contentView.height - backgroundH,
                                         width: contentLayoutFrame.width,
                                         height: backgroundH)
        case .footer:
            roundingCorners = [.bottomLeft, .bottomRight]
            backgroundFrame = CGRect(x: contentLayoutFrame.minX,
                                     y: 0.0,
                                     width: contentLayoutFrame.width,
                                     height: backgroundH)
        }
        
        backgroundLayer.frame = backgroundFrame
    
        let backgroundPath = UIBezierPath(roundedRect: CGRect(size: backgroundFrame.size),
                                          byRoundingCorners: roundingCorners,
                                          cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.fillColor = UIColor.secondarySystemGroupedBackground.cgColor
        
        
        CATransaction.commit()
    }
}
