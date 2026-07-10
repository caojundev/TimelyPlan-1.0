//
//  TPGrabberView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/8.
//

import Foundation
import UIKit

final class TPGrabberView: UIView {
    // MARK: - 可配置属性
    /// 抓手横线宽度
    var lineWidth: CGFloat = 36 {
        didSet { setNeedsLayout() }
    }
    /// 抓手横线高度
    var lineHeight: CGFloat = 5 {
        didSet { setNeedsLayout() }
    }
    /// 抓手颜色
    var lineColor: UIColor = .systemGray3 {
        didSet { grabberLineView.backgroundColor = lineColor }
    }
    
    /// 单击回调
    var onTap: (() -> Void)?
    
    // MARK: - 私有视图
    private let grabberLineView = UIView()
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        clipsToBounds = true
        backgroundColor = .clear
        // 圆角，和系统grabber保持一致
        grabberLineView.layer.cornerRadius = 2.5
        grabberLineView.clipsToBounds = true
        grabberLineView.backgroundColor = lineColor
        addSubview(grabberLineView)
        
        // 添加单击手势
        addGestureRecognizer(tapGesture)
    }
    
    // 手动布局核心：横线在父视图水平+垂直居中
    override func layoutSubviews() {
        super.layoutSubviews()
        grabberLineView.frame = CGRect(
            x: (bounds.width - lineWidth) / 2,
            y: (bounds.height - lineHeight) / 2,
            width: lineWidth,
            height: lineHeight
        )
    }
    
    @objc private func handleTap() {
        onTap?()
    }
    
    /// 快速获取系统默认尺寸的grabber视图（系统标准36×5）
    static func systemStyleGrabber() -> TPGrabberView {
        let view = TPGrabberView()
        view.lineWidth = 36
        view.lineHeight = 5
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20)
        return view
    }
}
