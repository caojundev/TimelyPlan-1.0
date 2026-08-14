//
//  TimelineConnectionCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation
import UIKit

// MARK: - 连接线基类 Cell

class TimelineConnectionCell: UICollectionViewCell {
    
    weak var delegate: AnyObject?
    
    let gradientLayer = CAGradientLayer()
    let shapeLayer = CAShapeLayer()
    
    // MARK: 连接线内容容器（子类在此添加内容）
    let connectionContentView = UIView()
    
    var item: TimelineConnectionItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        layer.addSublayer(gradientLayer)
        gradientLayer.mask = shapeLayer
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        
        // 添加连接线内容容器
        connectionContentView.backgroundColor = .clear
        contentView.addSubview(connectionContentView)
        setupConnectionContentSubviews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setupConnectionContentSubviews() {
        
    }
    
    func layoutConnectionContentSubviews() {
        
    }
    
    /// 配置连接线（子类可重写）
    func configure(with item: TimelineConnectionItem) {
        self.item = item
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = bounds
        updateGradientColors()
        
        let lineCenterX = TimelineConfig.leftTimeWidth + TimelineConfig.margin + 8.0 + TimelineConfig.centerNodeWidth / 2
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: lineCenterX, y: 0))
        path.addLine(to: CGPoint(x: lineCenterX, y: bounds.height))
        shapeLayer.path = path.cgPath
        
        CATransaction.commit()
        
        // 布局连接线内容容器
        let contentX = lineCenterX + TimelineConfig.centerNodeWidth / 2 + 12
        let contentWidth = bounds.width - contentX - TimelineConfig.margin
        connectionContentView.frame = CGRect(
            x: contentX,
            y: 0,
            width: contentWidth,
            height: bounds.height
        )
        
        layoutConnectionContentSubviews()
    }
    
    func updateGradientColors() {
        guard let item = item else {
            return
        }
        
        if item.topDate.isFutureDay {
            gradientLayer.colors = [TimelineConfig.futureNodeBackgroundColor.cgColor,
                                    TimelineConfig.futureNodeBackgroundColor.cgColor]
        } else {
            gradientLayer.colors = [item.topColor.cgColor, item.bottomColor.cgColor]
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        shapeLayer.path = nil
        
        CATransaction.commit()
    }
}

// MARK: - 实线连接线 Cell

class TimelineSolidConnectionCell: TimelineConnectionCell {
    
    override func configure(with item: TimelineConnectionItem) {
        super.configure(with: item)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        shapeLayer.lineWidth = TimelineConfig.solidLineWidth
        shapeLayer.lineDashPattern = nil
        
        CATransaction.commit()
    }
}

// MARK: - 虚线连接线 Cell
protocol TimelineDashedConnectionCellDelegate: AnyObject {
    
    func timelineDashedConnectionCellDidClickAdd(_ cell: TimelineDashedConnectionCell)
    
    func timelineDashedConnectionCellDidClickBind(_ cell: TimelineDashedConnectionCell)
}

class TimelineDashedConnectionCell: TimelineConnectionCell {
    
    lazy var titleView: TPImageTitleView = {
        let view = TPImageTitleView()
        view.accessoryPosition = .left
        view.titleConfig.font = .boldSystemFont(ofSize: 12.0)
        view.titleConfig.textAlignment = .left
        view.imageConfig.margins = UIEdgeInsets(right: 2.0)
        view.imageConfig.size = .size(3)
        view.imageConfig.shouldRenderImageWithColor = true
        view.imageConfig.color = .secondaryLabel
        view.titleConfig.textColor = .secondaryLabel
        return view
    }()
    
    private(set) lazy var addButton: TPDefaultButton = {
        let image = resGetImage("plus_24")
        let title = resGetString("Add")
        let button = newButton(image: image, title: title)
        button.addTarget(self, action: #selector(clickAdd), for: .touchUpInside)
        return button
    }()
    
    private(set) lazy var bindButton: TPDefaultButton = {
        let image = resGetImage("bind_24")
        let title = resGetString("Bind")
        let button = newButton(image: image, title: title)
        button.addTarget(self, action: #selector(clickBind), for: .touchUpInside)
        return button
    }()
    
    override func setupConnectionContentSubviews() {
        connectionContentView.addSubview(titleView)
        connectionContentView.addSubview(addButton)
        connectionContentView.addSubview(bindButton)
    }
    
    private let buttonTopMargin = 4.0
    
    override func layoutConnectionContentSubviews() {
        addButton.sizeToFit()
        bindButton.sizeToFit()
        
        titleView.width = connectionContentView.width
        titleView.height = 20.0
        titleView.top = (connectionContentView.height - (addButton.height + buttonTopMargin + titleView.height)) / 2.0
   
        addButton.top = titleView.bottom + buttonTopMargin
        bindButton.topEqualToView(addButton)
        bindButton.left = addButton.right + 8.0
    }
    
    override func configure(with item: TimelineConnectionItem) {
        super.configure(with: item)
        let interval = item.timeInterval
        if interval > 0 {
            titleView.title = Duration(interval).hourMinuteDurationString
        } else {
            titleView.title = nil
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        shapeLayer.lineWidth = TimelineConfig.dashedLineWidth
        shapeLayer.lineDashPattern = TimelineConfig.dashedPattern
        
        CATransaction.commit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleView.title = nil
    }
    
    @objc func clickAdd() {
        if let delegate = delegate as? TimelineDashedConnectionCellDelegate {
            delegate.timelineDashedConnectionCellDidClickAdd(self)
        }
    }
    
    @objc func clickBind() {
        if let delegate = delegate as? TimelineDashedConnectionCellDelegate {
            delegate.timelineDashedConnectionCellDidClickBind(self)
        }
    }
    
    private func newButton(image: UIImage?, title: String?) -> TPDefaultButton {
        let normalColor = Color(light: 0x000000, dark: 0xffffff, alpha: 0.8)
        let selectedColor = Color(light: 0x000000, dark: 0xffffff, alpha: 0.6)
        let button = TPDefaultButton()
        button.padding = UIEdgeInsets(top: 5.0, left: 4.0, bottom: 5.0, right: 8.0)
        button.preferredTappedScale = 0.9
        button.scaleMaxLength = 2.0
        button.cornerRadius = 6.0
        button.image = image
        button.imageConfig.shouldRenderImageWithColor = true
        button.imageConfig.color = normalColor
        button.imageConfig.selectedColor = selectedColor
        button.imageConfig.size = .size(4)
        button.imageConfig.margins = UIEdgeInsets(right: 2.0)
        button.title = title
        button.titleConfig.font = .boldSystemFont(ofSize: 11.0)
        button.titleConfig.textColor = normalColor
        button.titleConfig.selectedTextColor = selectedColor
        button.normalBackgroundColor = Color(light: 0x000000, dark: 0xffffff, alpha: 0.1)
        button.selectedBackgroundColor = Color(light: 0x000000, dark: 0xffffff, alpha: 0.2)
        return button
    }
}

// MARK: - 重叠连接线 Cell

class TimelineOverlappingConnectionCell: TimelineConnectionCell {
    
    lazy var titleView: TPImageTitleView = {
        let view = TPImageTitleView()
        view.accessoryPosition = .left
        view.titleConfig.font = .boldSystemFont(ofSize: 12.0)
        view.titleConfig.textAlignment = .left
        view.imageConfig.margins = UIEdgeInsets(right: 2.0)
        view.imageConfig.size = .size(3)
        view.imageConfig.shouldRenderImageWithColor = true
        view.imageConfig.color = .secondaryLabel
        view.titleConfig.textColor = .secondaryLabel
        view.image = resGetImage("myDay_overlapping_12")
        view.title = resGetString("Overlapping")
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        shapeLayer.lineWidth = TimelineConfig.overlappingLineWidth
        shapeLayer.lineDashPattern = nil
        CATransaction.commit()
    }
    
    override func updateGradientColors() {
        guard let item = item else {
            return
        }
        
        let backColor: UIColor
        if item.topDate.isFutureDay {
            backColor = TimelineConfig.futureNodeBackgroundColor
        } else {
            backColor = TimelineConfig.todayNodeBackgroundColor
        }
        
        let currentDate = Date()
        if currentDate >= item.topDate && currentDate >= item.bottomDate {
            gradientLayer.colors = [item.topColor.cgColor, item.bottomColor.cgColor]
        } else if currentDate >= item.topDate {
            gradientLayer.colors = [item.topColor.cgColor, backColor.cgColor]
        } else if currentDate >= item.bottomDate {
            gradientLayer.colors = [backColor.cgColor, item.bottomColor.cgColor]
        } else {
            gradientLayer.colors = [backColor.cgColor, backColor.cgColor]
        }
    }
    
    override func setupConnectionContentSubviews() {
        super.setupConnectionContentSubviews()
        connectionContentView.addSubview(titleView)
    }
    
    override func layoutConnectionContentSubviews() {
        super.layoutConnectionContentSubviews()
        titleView.width = connectionContentView.width
        titleView.height = 20.0
        titleView.alignVerticalCenter()
    }
}
