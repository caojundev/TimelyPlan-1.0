//
//  TPSeparatorTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/8.
//

import Foundation

class TPSeparatorTableCellItem: TPBaseTableCellItem {
    
    /// 分割线颜色
    var lineColor: UIColor = Color(0x888888, 0.2)
    
    /// 线条粗细
    var lineHeight: CGFloat = 0.8
    
    override init() {
        super.init()
        self.selectionStyle = .none
        self.registerClass = TPSeparatorTableCell.self
        self.contentPadding = UIEdgeInsets(horizontal: 16.0)
        self.height = 3.0
    }
}

class TPSeparatorTableCell: TPBaseTableCell {
 
    /// 线条宽度
    var lineHeight: CGFloat = 0.8 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 线条颜色
    var lineColor = Color(0x888888, 0.2) {
        didSet {
            separatorLayer.strokeColor = lineColor.cgColor
        }
    }
 
    private var separatorLayer = CAShapeLayer()
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPSeparatorTableCellItem else {
                return
            }

            lineHeight = cellItem.lineHeight
            lineColor = cellItem.lineColor
            setNeedsLayout()
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        separatorLayer.fillColor = UIColor.clear.cgColor
        separatorLayer.strokeColor = lineColor.cgColor
        contentView.layer.addSublayer(separatorLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorLayer.frame = contentView.layoutFrame()
        separatorLayer.lineWidth = lineHeight
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
