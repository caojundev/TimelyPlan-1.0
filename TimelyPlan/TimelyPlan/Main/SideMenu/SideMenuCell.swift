//
//  SideMenuActionCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/17.
//

import Foundation
import UIKit

class SideMenuCell: TPImageInfoTableCell {
    
    var menuAction: TPMenuAction? {
        didSet {
            guard let menuAction = menuAction else { return }
            imageContent = .withImage(menuAction.image)
            infoView.title = menuAction.title
        }
    }
   
    /// 选中指示视图
    private lazy var indicatorView: UIView = {
        let view = UIView()
        view.layer.backgroundColor = UIColor.primary.cgColor
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        imageConfig.size = .default
        imageConfig.shouldRenderImageWithColor = false
        titleConfig.textColor = Color(0xC0E3F4)
        contentView.addSubview(indicatorView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        indicatorView.frame = CGRect(x: contentView.bounds.maxX - 4, y: 0, width: 4, height: contentView.bounds.height)
        updateIndicator()
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        updateIndicator()
    }
    
    private func updateIndicator() {
        if isChecked {
            indicatorView.isHidden = false
            backgroundView?.backgroundColor = style?.selectedBackgroundColor
        } else {
            indicatorView.isHidden = true
            backgroundView?.backgroundColor = style?.backgroundColor
        }
    }
}
