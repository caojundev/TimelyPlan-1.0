//
//  PieRankListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/10.
//

import Foundation
import UIKit

class PieRankListCellItem: TPCollectionCellItem {
    
    let pieSlice: PieSlice

    let color: UIColor
    
    init(pieSlice: PieSlice, color: UIColor) {
        self.pieSlice = pieSlice
        self.color = color
        super.init()
        self.contentPadding = UIEdgeInsets(horizontal: 15.0, vertical: 10.0)
        self.registerClass = PieRankListCell.self
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? Self else {
            return false
        }
        
        return pieSlice == object.pieSlice
    }
}

class PieRankListCell: TPCollectionCell {
    
    let colorViewSize = CGSize(width: 8.0, height: 36.0)
    
    lazy var colorView: UIView = {
        let view = UIView()
        view.size = colorViewSize
        view.layer.cornerRadius = colorViewSize.width / 2.0
        return view
    }()
    
    lazy var infoView: TPInfoView = {
        let view = TPInfoView()
        view.titleConfig.font = BOLD_SYSTEM_FONT
        view.subtitleConfig.font = SMALL_SYSTEM_FONT
        view.subtitleConfig.textColor = .secondaryLabel
        view.subtitleConfig.lineBreakMode = .byTruncatingMiddle
        return view
    }()

    override var cellItem: TPCollectionCellItem? {
        didSet {
            let cellItem = cellItem as! PieRankListCellItem
            colorView.layer.backgroundColor = cellItem.color.cgColor
            infoView.title = cellItem.pieSlice.title
            infoView.subtitle = cellItem.pieSlice.detailPercentCombinedString
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
        contentView.addSubview(infoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        colorView.size = colorViewSize
        colorView.left = layoutFrame.minX
        colorView.alignVerticalCenter()
        
        let margin = 10.0
        let infoWidth = layoutFrame.width - colorViewSize.width - margin
        infoView.width = infoWidth
        infoView.height = layoutFrame.height
        infoView.left = colorView.right + margin
        infoView.top = layoutFrame.minY
    }
}
