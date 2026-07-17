//
//  CalendarEventPreviewInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/14.
//

import Foundation
import UIKit

// MARK: - Protocol

protocol CalendarEventPreviewDisplayable: AnyObject {
    var eventColor: UIColor { get }
    var eventTitle: String? { get }
    var dateInfo: (title: String?, subtitle: String?) { get }
    var sourceDescription: String? { get }
    var repeatInfo: (ruleDescription: String?, endDescription: String?)? { get }
    var alarmDescription: String? { get }
    var isEditable: Bool { get }
    var isDeletable: Bool { get }
}

final class CalendarEventPreviewInfoView: UIView {
    
    // MARK: - Properties
    
    var event: CalendarEventPreviewDisplayable? {
        didSet {
            updateContent()
        }
    }
    
    private let colorIndicatorView = UIView()
    private let titleLabel = TPLabel()
    private let dateInfoView = TPInfoView()
    private let sourceLabel = TPLabel()
    
    // MARK: - Constants
    
    private enum Constants {
        static let colorIndicatorSize = CGSize.size(4)
        static let colorIndicatorCornerRadius: CGFloat = 8.0
        static let titleLabelHeight: CGFloat = 50.0
        static let dateInfoViewHeight: CGFloat = 40.0
        static let sourceLabelHeight: CGFloat = 25.0
        static let horizontalSpacing: CGFloat = 16.0
        
        static let defaultPadding = UIEdgeInsets(
            top: 10.0,
            left: 50.0,
            bottom: 10.0,
            right: 16.0
        )
    }
    
    // MARK: - Computed Properties
    static var contentHeight: CGFloat {
        return Constants.defaultPadding.verticalLength +
               Constants.titleLabelHeight +
               Constants.dateInfoViewHeight +
               Constants.sourceLabelHeight
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        padding = Constants.defaultPadding
        setupSubviews()
    }
    
    private func setupSubviews() {
        // Color indicator
        colorIndicatorView.clipsToBounds = true
        colorIndicatorView.layer.cornerRadius = Constants.colorIndicatorCornerRadius
        addSubview(colorIndicatorView)
        
        // Title label
        titleLabel.font = .boldSystemFont(ofSize: 18.0)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .label
        titleLabel.alpha = 0.9
        addSubview(titleLabel)
        
        // Date info view
        dateInfoView.titleConfig.font = .systemFont(ofSize: 14.0)
        dateInfoView.titleConfig.textColor = .secondaryLabel
        dateInfoView.subtitleConfig.font = .systemFont(ofSize: 14.0)
        dateInfoView.subtitleConfig.textColor = .secondaryLabel
        addSubview(dateInfoView)
        
        // Source label
        sourceLabel.font = .systemFont(ofSize: 13.0)
        sourceLabel.textColor = .tertiaryLabel
        addSubview(sourceLabel)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = layoutFrame()
        
        // Layout title label
        titleLabel.frame = CGRect(
            x: contentFrame.minX,
            y: contentFrame.minY,
            width: contentFrame.width,
            height: Constants.titleLabelHeight
        )
        
        // Layout color indicator
        colorIndicatorView.frame = CGRect(
            x: contentFrame.minX - Constants.colorIndicatorSize.width - Constants.horizontalSpacing,
            y: titleLabel.center.y - Constants.colorIndicatorSize.height / 2,
            width: Constants.colorIndicatorSize.width,
            height: Constants.colorIndicatorSize.height
        )
    
        // Layout date info view
        dateInfoView.frame = CGRect(
            x: contentFrame.minX,
            y: titleLabel.frame.maxY,
            width: contentFrame.width,
            height: Constants.dateInfoViewHeight
        )
        
        // Layout source label
        sourceLabel.frame = CGRect(
            x: contentFrame.minX,
            y: dateInfoView.frame.maxY,
            width: contentFrame.width,
            height: Constants.sourceLabelHeight
        )
    }
    
    // MARK: - Content Update
    
    private func updateContent() {
        guard let event = event else { return }
        
        colorIndicatorView.backgroundColor = event.eventColor
        titleLabel.text = event.eventTitle
        let dateInfo = event.dateInfo
        dateInfoView.title = dateInfo.title
        dateInfoView.subtitle = dateInfo.subtitle
        sourceLabel.text = event.sourceDescription
    }
}
