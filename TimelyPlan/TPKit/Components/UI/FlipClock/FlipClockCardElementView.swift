//
//  FlipClockCardView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/2.
//

import Foundation
import UIKit

class FlipClockCardElementView: UIView {
    
    var text: String? {
        didSet {
            topView.text = text
            bottomView.text = text
        }
    }
   
    /// 圆角半径
    var cornerRadius: CGFloat = 0.0
    
    /// 文本字体
    var font: UIFont? = .robotoMonoBoldFont(size: 300.0)
    
    /// 文本颜色
    var textColor: UIColor = Color(0xFFFFFF, 0.8)
    
    /// 背景颜色
    var backColor: UIColor? = Color(0x222222)
    
    /// 阴影半径
    var shadowRadius: CGFloat = 16.0
    
    /// 阴影颜色
    var shadowColor: UIColor = Color(0x000000, 0.6)
    
    /// 内容间距
    var contentPadding: UIEdgeInsets = .zero
    
    /// 分割区域空白高度
    var spacing: CGFloat = 8.0
    
    private let contentView = UIView()
    
    let topView = FlipClockElementHalfView(style: .top)
    let bottomView = FlipClockElementHalfView(style: .bottom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        contentView.clipsToBounds = false
        addSubview(contentView)
        contentView.addSubview(topView)
        contentView.addSubview(bottomView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        contentView.frame = bounds
        topView.frame = bounds
        bottomView.frame = bounds
        updateStyle(for: topView)
        updateStyle(for: bottomView)
        CATransaction.commit()
    }
    
    func updateStyle(for view: FlipClockElementHalfView) {
        view.contentPadding = contentPadding
        view.cornerRadius = cornerRadius
        view.spacing = spacing
        view.textColor = textColor
        view.backColor = backColor
        view.font = font
        view.shadowRadius = shadowRadius
        view.shadowColor = shadowColor
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    private func rotationTransform(withAngle degrees: CGFloat) -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 800.0
        transform = CATransform3DRotate(transform, degrees.degreesToRadians, 1, 0, 0)
        return transform
    }
    
    func reset() {
        resetTopHalf()
        resetBottomHalf()
        bottomView.alpha = 1.0
    }
    
    private func resetTopHalf() {
        topView.layer.transform = CATransform3DIdentity
    }
    
    private func resetBottomHalf() {
        /// 将下半部分转动至中间（90度）
        bottomView.layer.transform = rotationTransform(withAngle: 90.0)
    }
    
    func rotateTopHalfToMiddle(duration: CGFloat,
                               animations: (() -> Void)?,
                               completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseIn) {
            let transform = self.rotationTransform(withAngle: -90.0)
            self.topView.layer.transform = transform
            animations?()
        } completion: { finished in
            completion?(finished)
        }
    }
    
    func rotateBottomHalfFromMiddle(duration: CGFloat,
                                    animations: (() -> Void)?,
                                    completion: ((Bool) -> Void)? = nil) {
        resetBottomHalf()
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.4,
                       options: .curveEaseInOut) {
            self.bottomView.layer.transform = self.rotationTransform(withAngle: 1.0)
            animations?()
        } completion: { finished in
            completion?(finished)
        }
    }
}

