//
//  ReasonTagTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/18.
//

import Foundation
import UIKit

class ReasonTagTableCell: TPDefaultInfoTableCell {
    
    var reasonTag: ReasonTag? {
        didSet {
            emojiLabel.text = reasonTag?.emoji
            title = reasonTag?.reason
        }
    }
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30.0)
        label.textAlignment = .center
        return label
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.leftView = emojiLabel
        self.leftViewSize = .size(12)
        self.leftViewMargins = UIEdgeInsets(right: 12.0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.emojiLabel.layer.backgroundColor = UIColor.tertiarySystemGroupedBackground.cgColor
        self.emojiLabel.layer.cornerRadius = self.leftViewSize.halfHeight
    }
}
