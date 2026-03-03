//
//  HabitHomeDayTaskCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/3.
//

import Foundation
import UIKit

class HabitHomeDayTaskCell: TPCollectionCell {
    
    /// 遮罩视图
    private let coverView = UIView()
    
    /// 阴影视图
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.layer.shadowColor = Color(0x666666, 0.6).cgColor
        view.layer.shadowOffset = CGSize(width:0, height: 4.0)
        view.layer.shadowRadius = 4.0
        view.layer.shadowOpacity = 0.6
        return view
    }()
    
    private lazy var infoView: HabitTaskProgressInfoView = {
        let view = HabitTaskProgressInfoView()
        return view
    }()
    
    /// 更多按钮
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.imageConfig.color = Color(0xffffff, 0.8)
        button.addTarget(self,
                         action: #selector(clickMore(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        insertSubview(shadowView, belowSubview: contentView)
        contentView.padding = UIEdgeInsets(left: 16.0, right: 16.0)
        contentView.addSubview(coverView)
        contentView.addSubview(infoView)
        contentView.addSubview(moreButton)
        
        let color = UIColor.randomHabitTaskColor
        updateStyleWithColor(UIColor.randomHabitTaskColor)

        infoView.iconView.icon = TPIcon(text: Character.randomEmojiString())
        infoView.titleView.title = "阅读文档"
        infoView.titleView.subtitle = "每天阅读100页"
        let progress = CGFloat(arc4random() % 100) / 100.0
        infoView.setProgress(progress, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
    
        let radius = contentView.layer.cornerRadius
        shadowView.frame = bounds
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: bounds,
                                                   cornerRadius: radius).cgPath
        
        coverView.frame = bounds
        coverView.layer.cornerRadius = radius
        coverView.layer.backgroundColor = Color(0x000000, 0.1).cgColor
        
        let layoutFrame = contentView.layoutFrame()
        moreButton.sizeToFit()
        moreButton.right = layoutFrame.maxX
        moreButton.alignVerticalCenter()
        
        infoView.width = layoutFrame.width - moreButton.width
        infoView.height = layoutFrame.height
        infoView.origin = layoutFrame.origin
    }
    
    func updateStyleWithColor(_ color: UIColor) {
        contentView.backgroundColor = color.withBrightness(0.5)
        
        let iconView = infoView.iconView
        iconView.foreColor = Color(0xffffff, 0.8)
        iconView.backColor = color
        
        let titleView = infoView.titleView
        titleView.titleConfig.textColor = Color(0xffffff, 0.9)
        titleView.subtitleConfig.textColor = Color(0xffffff, 0.7)
        
        let progressView = infoView.progressView
        let progressLineColor = color.lighterColor
        progressView.progressLineColor = progressLineColor
        progressView.backLineColor = Color(0x000000, 0.4)
    }
    
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {

    }
}
