//
//  TPCalendarDayBadgeView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/27.
//

import Foundation
import UIKit

class TPCalendarDayBadgeView: UIView {

    var state: TPDateState = .onHoliday {
        didSet {
            setNeedsLayout()
        }
    }
    
    lazy var textLabel: TPLabel = {
        let label = TPLabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.isHidden = state == .inNormal
        self.layer.cornerRadius = bounds.boundingCornerRadius
        switch state {
        case .inNormal:
            self.backgroundColor = .clear
        case .inWorking:
            self.backgroundColor = Color(0xFF3B30)
        case .onHoliday:
            self.backgroundColor = Color(0x34C759)
        }
        
        self.textLabel.frame = bounds.inset(by: UIEdgeInsets(value: 1.0))
        self.textLabel.text = state.title
        self.textLabel.textColor = .white
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: 12.0, height: 12.0)
    }
}
