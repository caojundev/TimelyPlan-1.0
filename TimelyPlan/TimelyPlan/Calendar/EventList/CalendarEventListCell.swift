//
//  CalendarEventListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/31.
//

import Foundation
import UIKit

class CalendarEventListCell: TPDefaultInfoTableCell {
    
    var event: CalendarEvent? {
        didSet {
            updateEventInfo()
        }
    }
    
    let colorViewSize = CGSize(width: 4.0, height: 32.0)
    let colorViewMargins = UIEdgeInsets(right: 12.0)
    
    lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = colorViewSize.width / 2.0
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        infoView.leftAccessoryView = colorView
        infoView.leftAccessorySize = colorViewSize
        infoView.leftAccessoryMargins = colorViewMargins
    }
    
    func updateEventInfo() {
        guard let event = event else {
            return
        }

        colorView.backgroundColor = event.color
        infoView.title = event.title
        infoView.subtitle = event.notes
    }
}

