//
//  QuadrantLayoutEditCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/20.
//

import Foundation
import UIKit

class QuadrantLayoutEditCell: TPCollectionCell {

    var quadrant: Quadrant {
        get {
            return titleView.quadrant
        }
        
        set {
            titleView.quadrant = newValue
            imageView.image = resGetImage(quadrant.placeholderImageName)
            setNeedsLayout()
        }
    }
    
    var titlePosition: QuadrantTitlePosition {
        get {
            return titleView.position
        }
        
        set {
            titleView.position = newValue
            setNeedsLayout()
        }
    }
    
    private let titleViewHeight = 40.0
    
    private lazy var titleView: QuadrantTitleView = {
        let view = QuadrantTitleView(quadrant: .urgentImportant)
        view.addButton.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.scaleWhenHighlighted = false
        contentView.addSubview(imageView)
        contentView.addSubview(titleView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleView.width = bounds.width
        titleView.height = titleViewHeight
        imageView.width = bounds.width
        imageView.height = bounds.height - titleViewHeight
        
        if titlePosition == .top {
            titleView.top = 0.0
            imageView.top = titleView.bottom
        } else {
            imageView.top = 0.0
            titleView.bottom = bounds.height
        }
        
        imageView.updateContentMode()
        imageView.updateImage(withColor: .systemGray4)
    }
    
    override func updateCellStyle() {
        super.updateCellStyle()
        backgroundView?.backgroundColor = .secondarySystemGroupedBackground
        selectedBackgroundView?.backgroundColor = .secondarySystemGroupedBackground
    }
}
