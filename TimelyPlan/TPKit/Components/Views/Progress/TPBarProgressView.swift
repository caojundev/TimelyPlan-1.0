//
//  TPBarProgressView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/16.
//

import Foundation
import UIKit

class TPBarProgressView: UIView {
    
    enum Style {
        case horizontal
        case vertical
    }
    
    /// 进度条样式
    let style: Style
    
    /// 是否翻转，翻转后从 1 到 0
    var isReversed: Bool = false
    
    /// 圆角半径
    var cornerRadius: CGFloat = 0.0
    
    /// 进度色
    var barForeColor: UIColor = .primary {
        didSet {
            if barForeColor != oldValue {
                progressLayer.backgroundColor = barForeColor.cgColor
            }
        }
    }
    
    /// 进度背景色
    var barBackColor: UIColor = Color(0x888888, 0.1){
        didSet {
            if barBackColor != oldValue {
                backLayer.backgroundColor = barBackColor.cgColor
            }
        }
    }
   
    /// 动画时长
    var animateDuration: CGFloat = 0.25
   
    /// 进度
    var progress: CGFloat {
        get {
            return _progress
        }
        
        set {
            setProgress(newValue, animated: false)
        }
    }
    
    /// 进度
    private var _progress: CGFloat = 0.0
    
    /// 进度图层
    private var progressLayer = CALayer()
    
    /// 背景图层
    private var backLayer = CALayer()

    init(frame: CGRect = .zero, style: Style = .horizontal) {
        self.style = style
        super.init(frame: frame)
        self.layer.addSublayer(backLayer)
        self.layer.addSublayer(progressLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let backCornerRadius = min(cornerRadius, bounds.boundingCornerRadius)
        backLayer.backgroundColor = barBackColor.cgColor
        backLayer.frame = bounds
        backLayer.cornerRadius = backCornerRadius
        
        progressLayer.backgroundColor = barForeColor.cgColor
        updateProgress()
    }
    
    private func updateProgress(animated: Bool = false, completion: (() -> Void)? = nil) {
        let progress = isReversed ? (1.0 - progress) : progress
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        CATransaction.setAnimationDuration(animateDuration)
        CATransaction.setCompletionBlock(completion)
        if style == .horizontal {
            progressLayer.frame = CGRect(x: 0, y: 0, width: width * progress, height: height)
        } else {
            let h = height * progress
            let y = height - h
            progressLayer.frame = CGRect(x: 0, y: y, width: width, height: h)
        }
        
        /// 进度图层的圆角半径不能超过其自身尺寸的一半：
        /// 进度为 0 时长度为 0，若仍按视图尺寸取圆角，圆角路径会向左溢出，
        /// 在进度条最左端绘制出一小块进度颜色（拖动排序生成快照时尤为明显）
        progressLayer.cornerRadius = min(cornerRadius, progressLayer.bounds.boundingCornerRadius)
        /// 进度为 0 时完全透明，避免快照渲染出现残留色块
        progressLayer.opacity = progress <= 0.0 ? 0.0 : 1.0
        
        CATransaction.commit()
    }
    
    // MARK: - Public Methods
    func setProgress(_ progress: CGFloat, animated: Bool = false, completion: (() -> Void)? = nil) {
        _progress = min(max(0.0, progress), 1.0)
        updateProgress(animated: animated, completion: completion)
    }
}
