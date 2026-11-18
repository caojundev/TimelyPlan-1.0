//
//  MyDayTimelineIconNodeView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/14.
//

import Foundation
import UIKit

class MyDayTimelineIconNodeView: MyDayTimelineNodeView {
    
    // MARK: 子视图
    let iconImageView = UIImageView()

    override func setupView() {
        super.setupView()
        
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)
    }
    
    /// 配置图标
    func configureIcon(_ icon: UIImage?) {
        iconImageView.image = icon
    }
    
    // MARK: 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.frame = CGRect(
            x: 0,
            y: contentView.centerY - MyDayTimelineStyle.iconSize / 2.0,
            width: MyDayTimelineStyle.centerNodeWidth,
            height: MyDayTimelineStyle.iconSize
        )
    }
}
