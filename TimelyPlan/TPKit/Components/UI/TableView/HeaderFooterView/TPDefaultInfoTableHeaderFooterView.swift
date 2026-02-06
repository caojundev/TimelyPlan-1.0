//
//  TPDefaultInfoTableHeaderFooterView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/4.
//

import Foundation
import UIKit

class TPDefaultInfoTableHeaderFooterItem: TPBaseTableHeaderFooterItem {
    
    var title: TextRepresentable?
    
    var subtitle: TextRepresentable?
    
    var titleConfig: TPLabelConfig = .titleConfig
    
    var subtitleConfig: TPLabelConfig = .subtitleConfig

    override init() {
        super.init()
        self.registerClass = TPDefaultInfoTableHeaderFooterView.self
        self.padding = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
    }
}

class TPDefaultInfoTableHeaderFooterView: TPBaseTableHeaderFooterView {
    
    override var headerFooterItem: TPBaseTableHeaderFooterItem? {
        didSet {
            guard let headerFooterItem = headerFooterItem as? TPDefaultInfoTableHeaderFooterItem else {
                return
            }
            
            title = headerFooterItem.title
            subtitle = headerFooterItem.subtitle
            titleConfig = headerFooterItem.titleConfig
            subtitleConfig = headerFooterItem.subtitleConfig
        }
    }
    
    var title: TextRepresentable? {
        get {
            return infoView.title
        }
        
        set {
            infoView.title = newValue
        }
    }
    
    var subtitle: TextRepresentable? {
        get {
            return infoView.subtitle
        }
        
        set {
            infoView.subtitle = newValue
        }
    }
    
    var titleConfig: TPLabelConfig {
        get {
            return infoView.titleConfig
        }
        
        set {
            infoView.titleConfig = newValue
        }
    }
    
    var subtitleConfig: TPLabelConfig {
        get {
            return infoView.subtitleConfig
        }
        
        set {
            infoView.subtitleConfig = newValue
        }
    }
    
    /// 信息视图
    lazy var infoView: TPInfoView = {
        let view = TPInfoView()
        view.subtitleTopMargin = 5.0
        view.titleConfig.numberOfLines = 1
        view.subtitleConfig.numberOfLines = 1
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        setupInfoView()
        contentView.addSubview(infoView)
    }
    
    func setupInfoView() {

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = availableLayoutFrame()
    }
}
