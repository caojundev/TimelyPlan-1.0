//
//  TPSeparatorTableHeaderFooterView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/17.
//

import Foundation
import UIKit

class TPSeparatorTableHeaderFooterItem: TPDefaultInfoTableHeaderFooterItem {
    
    /// 分割线颜色
    var lineColor: UIColor = Color(0x888888, 0.1)
    
    /// 线条粗细
    var lineHeight: CGFloat = 1.0
    
    /// 背景色
    var backgroundColor: UIColor = .clear
    
    override init() {
        super.init()
        self.padding = UIEdgeInsets(horizontal: 15.0)
        self.registerClass = TPSeparatorTableHeaderFooterView.self
        self.height = 1.0
    }
}

class TPSeparatorTableHeaderFooterView: TPDefaultInfoTableHeaderFooterView {
    
    override var headerFooterItem: TPBaseTableHeaderFooterItem? {
        didSet {
            guard let headerFooterItem = headerFooterItem as? TPSeparatorTableHeaderFooterItem else {
                return
            }
            
            self.lineHeight = headerFooterItem.lineHeight
            self.lineColor = headerFooterItem.lineColor
            contentView.backgroundColor = headerFooterItem.backgroundColor
            setNeedsLayout()
        }
    }
    
    private var separatorLayer: CAShapeLayer!
    
    /// 线条宽度
    var lineHeight: CGFloat = 0.8
    
    /// 线条颜色
    var lineColor: UIColor? = Color(0x888888, 0.1)
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        separatorLayer = CAShapeLayer()
        separatorLayer.fillColor = UIColor.clear.cgColor
        contentView.layer.addSublayer(separatorLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        let strokeColor = lineColor ?? .separator
        separatorLayer.strokeColor = strokeColor.cgColor
        separatorLayer.lineWidth = lineHeight
        separatorLayer.frame = layoutFrame
        updateLayerPath()
    }
    
    private func updateLayerPath() {
        let layoutFrame = separatorLayer.bounds
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: layoutFrame.minX, y: layoutFrame.midY))
        linePath.addLine(to: CGPoint(x: layoutFrame.maxX, y: layoutFrame.midY))
        separatorLayer.path = linePath.cgPath
    }
}
