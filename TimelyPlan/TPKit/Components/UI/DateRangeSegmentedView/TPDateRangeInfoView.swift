//
//  TPDateRangeInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/22.
//

import Foundation
import UIKit

class TPDateRangeInfoView: UIView {
    
    var headerTextColor: UIColor {
        get {
            return headerLabel.textColor
        }
        
        set {
            headerLabel.textColor = newValue
        }
    }
    
    var titleTextColor: UIColor? {
        get {
            return detailView.titleConfig.textColor
        }
        
        set {
            detailView.titleConfig.textColor = newValue
        }
    }
    
    var subtitleTextColor: UIColor? {
        get {
            return detailView.subtitleConfig.textColor
        }
        
        set {
            detailView.subtitleConfig.textColor = newValue
        }
    }
    
    
    
    var detailTitle: TextRepresentable? {
        get {
            return detailView.title
        }
        
        set {
            detailView.title = newValue
        }
    }
    
    var detailSubtitle: TextRepresentable? {
        get {
            return detailView.subtitle
        }
        
        set {
            detailView.subtitle = newValue
        }
    }
    
    private(set) lazy var headerLabel: TPLabel = {
        let label = TPLabel()
        label.font = .boldSystemFont(ofSize: 12.0)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = resGetColor(.title)
        label.alpha = 0.8
        return label
    }()
    
    /// 详细视图
    private(set) var detailView: TPInfoView = {
        let view = TPInfoView()
        view.isUserInteractionEnabled = false
        view.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        view.titleConfig.adjustsFontSizeToFitWidth = true
        view.subtitleTopMargin = 8.0
        view.subtitleConfig.font = .boldSystemFont(ofSize: 10.0)
        view.subtitleLabel.alpha = 0.6
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.headerLabel)
        self.addSubview(self.detailView)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        headerLabel.width = layoutFrame.width
        headerLabel.height = layoutFrame.height * 0.4
        headerLabel.top = layoutFrame.minY
        headerLabel.left = layoutFrame.minX
        
        detailView.width = layoutFrame.width
        detailView.height = layoutFrame.height - headerLabel.height
        detailView.left = layoutFrame.minX
        detailView.top = headerLabel.bottom
    }
}


