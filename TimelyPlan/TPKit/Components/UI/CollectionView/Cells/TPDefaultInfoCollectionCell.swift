//
//  TPDefaultInfoCollectionCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/19.
//

import Foundation

class TPDefaultInfoCollectionCellItem: TPCollectionCellItem {
    
    var title: TextRepresentable?
    
    var subtitle: TextRepresentable?
    
    var titleConfig: TPLabelConfig = .titleConfig
    
    var subtitleConfig: TPLabelConfig = .subtitleConfig
    
    /// 副标题顶部间距
    var subtitleTopMargin: CGFloat = 5.0
    
    /// 左侧视图尺寸
    var leftAccessorySize: CGSize = .zero
    
    /// 左侧视图外间距
    var leftAccessoryMargins: UIEdgeInsets = .zero
    
    /// 右侧视图尺寸
    var rightAccessorySize: CGSize = .zero
    
    /// 右侧视图外间距
    var rightAccessoryMargins: UIEdgeInsets = .zero
    
    override init() {
        super.init()
        self.registerClass = TPDefaultInfoCollectionCell.self
    }
}

class TPDefaultInfoCollectionCell: TPCollectionCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPDefaultInfoCollectionCellItem else {
                return
            }
  
            title = cellItem.title
            subtitle = cellItem.subtitle
            titleConfig = cellItem.titleConfig
            subtitleConfig = cellItem.subtitleConfig
            infoView.subtitleTopMargin = cellItem.subtitleTopMargin
            infoView.leftAccessorySize = cellItem.leftAccessorySize
            infoView.leftAccessoryMargins = cellItem.leftAccessoryMargins
            infoView.rightAccessorySize = cellItem.rightAccessorySize
            infoView.rightAccessoryMargins = cellItem.rightAccessoryMargins
            setNeedsLayout()
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
    var infoView = TPInfoView()
    
    func setupInfoView() {
        
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        setupInfoView()
        contentView.addSubview(infoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = contentView.layoutFrame()
        infoView.isHighlighted = isHighlighted
        infoView.isSelected = isSelected || isChecked
    }
}
