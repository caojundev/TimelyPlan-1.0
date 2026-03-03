//
//  HabitTaskDefaultInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/3.
//

import Foundation
import UIKit

class HabitTaskDefaultInfoView: UIView {
    
    /// 图标尺寸
    var iconSize = CGSize.size(12)

    /// 任务图标视图
    lazy var iconView: TPIconView = {
        let view = TPIconView()
        view.borderWidth = 0.0
        view.placeholderCharacter = "C"
        view.size = iconSize
        view.cornerRadius = iconSize.halfHeight
        return view
    }()
    
    /// 信息视图
    lazy var titleView: TPInfoView = {
        let view = TPInfoView()
        view.padding = UIEdgeInsets(left: 10.0)
        view.titleConfig.textAlignment = .left
        view.titleConfig.font = BOLD_BODY_FONT
        view.subtitleConfig.textAlignment = .left
        view.subtitleConfig.font = BOLD_SMALL_SYSTEM_FONT
        view.subtitleLabel.alpha = 0.6
        return view
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(iconView)
        addSubview(titleView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        iconView.left = layoutFrame.minX
        iconView.centerY = layoutFrame.midY
        
        titleView.width = layoutFrame.width - iconSize.width
        titleView.height = layoutFrame.height
        titleView.left = iconView.right
        titleView.top = layoutFrame.minY
    }
}
