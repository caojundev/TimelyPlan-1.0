//
//  CalendarWeekNumberView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/12.
//

import Foundation
import UIKit

class CalendarWeekNumberView: UIView {
    
    // MARK: - Public Properties
    public var weekNumber: Int = 0 {
        didSet {
            weekLabel.text = "\(weekNumber)"
        }
    }
    
    public var weekText: String = resGetString("W") {
        didSet {
            weekTextLabel.text = weekText
        }
    }
    
    var numberHeight: CGFloat? {
        didSet {
            if numberHeight != oldValue {
                setNeedsLayout()
            }
        }
    }

    // 可自定义样式
    public var weekNumberFont: UIFont = .boldSystemFont(ofSize: 12.0) {
        didSet { weekLabel.font = weekNumberFont }
    }
    
    public var weekTextFont: UIFont = .systemFont(ofSize: 10.0) {
        didSet { weekTextLabel.font = weekTextFont }
    }
    
    public var weekNumberColor: UIColor = .label {
        didSet { weekLabel.textColor = weekNumberColor }
    }
    
    public var weekTextColor: UIColor = .secondaryLabel {
        didSet { weekTextLabel.textColor = weekTextColor }
    }
    
    public var textAlignment: NSTextAlignment = .center {
        didSet {
            weekLabel.textAlignment = textAlignment
            weekTextLabel.textAlignment = textAlignment
        }
    }
    
    // MARK: - Private Subviews
    private let weekLabel = UILabel()
    private let weekTextLabel = UILabel()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup
    private func setupViews() {
        weekLabel.adjustsFontSizeToFitWidth = true
        weekTextLabel.adjustsFontSizeToFitWidth = true
        
        weekLabel.font = weekNumberFont
        weekTextLabel.font = weekTextFont
        
        weekLabel.textColor = weekNumberColor
        weekTextLabel.textColor = weekTextColor
        
        weekLabel.textAlignment = .center
        weekTextLabel.textAlignment = .center
        
        weekLabel.text = "\(weekNumber)"
        weekTextLabel.text = weekText
        
        addSubview(weekLabel)
        addSubview(weekTextLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        weekLabel.width = layoutFrame.width
        if let numberHeight = numberHeight {
            weekLabel.height = numberHeight
        } else {
            weekLabel.height = layoutFrame.size.halfHeight
        }
    
        weekLabel.origin = layoutFrame.origin
        
        weekTextLabel.width = layoutFrame.width
        weekTextLabel.height = layoutFrame.height - weekLabel.height
        weekTextLabel.left = layoutFrame.minX
        weekTextLabel.top = weekLabel.bottom
    }
}
