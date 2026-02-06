//
//  TPMenuListActionCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/28.
//

import Foundation

class TPMenuListActionCell: TPImageInfoTextValueTableCell {
    
    var menuAction: TPMenuAction? {
        didSet {
            imageConfig.color = menuAction?.iconColor
            imageContent = .withImage(menuAction?.image)
            valueConfig = .valueText(menuAction?.valueText)
            infoView.titleConfig.textColor = menuAction?.titleColor ?? resGetColor(.title)
            infoView.title = menuAction?.title
            infoView.subtitle = menuAction?.subtitle
             
            let isChecked = menuAction?.isChecked ?? false
            setChecked(isChecked, animated: false)
            setNeedsLayout()
        }
    }
    
    lazy var checkmarkView: UIImageView = {
        let view = UIImageView()
        view.image = resGetImage("checkmark_24")
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        imageConfig.shouldRenderImageWithColor = true
        imageConfig.size = .mini
        subtitleConfig.font = UIFont.boldSystemFont(ofSize: 10.0)
        rightView = checkmarkView
        setChecked(false, animated: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkmarkView.updateImage(withColor: tintColor)
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkmarkView.isHidden = !checked
        rightViewSize = checked ? .mini : .zero
    }
}
