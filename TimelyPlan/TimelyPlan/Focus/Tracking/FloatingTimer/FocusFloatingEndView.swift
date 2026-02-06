//
//  FocusFloatingEndView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/26.
//

import Foundation
import UIKit

class FocusFloatingEndView: UIView {

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = resGetImage("checkmark_circle_fill_24")
        imageView.contentMode = .scaleAspectFit
        imageView.updateImage(withColor: .white)
        return imageView
    }()

    /// 标题视图
    private let titleLabelHeight = 30.0
    private lazy var titleLabel: TPLabel = {
        let label = TPLabel()
        label.edgeInsets = UIEdgeInsets(horizontal: 5.0)
        label.backgroundColor = Color(0x343434)
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.textColor = Color(0xFFFFFF, 0.6)
        label.adjustsFontSizeToFitWidth = true
        label.text = resGetString("Completed")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .success6
        self.addSubview(imageView)
        self.addSubview(titleLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.sizeToFit()
        imageView.centerX = halfWidth
        imageView.centerY = (height - titleLabelHeight) / 2.0
        
        titleLabel.width = width
        titleLabel.height = titleLabelHeight
        titleLabel.bottom = height
    }
}
