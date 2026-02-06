//
//  TPDefaultTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/27.
//

import Foundation
import UIKit

class TPDefaultInfoTableCellLayout: TPBaseTableCellLayout {
    
    var titleContent: TPLabelContent? {
        didSet {
            if titleContent != oldValue {
                setNeedsLayout()
            }
        }
    }
        
    var subtitleContent: TPLabelContent? {
        didSet {
            if subtitleContent != oldValue {
                setNeedsLayout()
            }
        }
    }
        
    var titleConfig: TPLabelConfig = .titleConfig {
        didSet {
            if titleConfig != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    var subtitleConfig: TPLabelConfig = .subtitleConfig {
        didSet {
            if subtitleConfig != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 副标题顶部间距
    var subtitleTopMargin: CGFloat = 5.0 {
        didSet {
            if subtitleTopMargin != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 左侧视图尺寸
    var leftAccessorySize: CGSize = .zero {
        didSet {
            if leftAccessorySize != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 左侧视图外间距
    var leftAccessoryMargins: UIEdgeInsets = .zero {
        didSet {
            if leftAccessoryMargins != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 右侧视图尺寸
    var rightAccessorySize: CGSize = .zero {
        didSet {
            if rightAccessorySize != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 右侧视图外间距
    var rightAccessoryMargins: UIEdgeInsets = .zero {
        didSet {
            if rightAccessoryMargins != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    override func getContentHeight() -> CGFloat {
        let infoViewLayout = infoViewLayout()
        let constraintWidth = avaliableLayoutWidth()
        let size = infoViewLayout.boundingSize(with: constraintWidth)
        return size.height
    }
    
    func infoViewLayout() -> TPInfoViewLayout {
        let layout = TPInfoViewLayout()
        layout.titleContent = titleContent
        layout.subtitleContent = subtitleContent
        layout.titleConfig = titleConfig
        layout.subtitleConfig = subtitleConfig
        layout.subtitleTopMargin = subtitleTopMargin
        layout.leftAccessorySize = leftAccessorySize
        layout.leftAccessoryMargins = leftAccessoryMargins
        layout.rightAccessorySize = rightAccessorySize
        layout.rightAccessoryMargins = rightAccessoryMargins
        return layout
    }
}

class TPDefaultInfoTableCellItem: TPBaseTableCellItem {
    
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
        self.registerClass = TPDefaultInfoTableCell.self
        self.setLayout(TPDefaultInfoTableCellLayout())
    }
    
    override func getLayout() -> TPBaseTableCellLayout {
        let layout = super.getLayout() as! TPDefaultInfoTableCellLayout
        layout.titleContent = .withText(title)
        layout.subtitleContent = .withText(subtitle)
        layout.titleConfig = titleConfig
        layout.subtitleConfig = subtitleConfig
        layout.subtitleTopMargin = subtitleTopMargin
        layout.leftAccessorySize = leftAccessorySize
        layout.leftAccessoryMargins = leftAccessoryMargins
        layout.rightAccessorySize = rightAccessorySize
        layout.rightAccessoryMargins = rightAccessoryMargins
        return layout
    }
}

class TPDefaultInfoTableCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPDefaultInfoTableCellItem else {
                return
            }
            
            titleConfig = cellItem.titleConfig
            subtitleConfig = cellItem.subtitleConfig
            title = cellItem.title
            subtitle = cellItem.subtitle
            infoView.subtitleTopMargin = cellItem.subtitleTopMargin
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
    lazy var infoView: TPInfoView = {
        let view = TPInfoView()
        view.subtitleTopMargin = 5.0
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = availableLayoutFrame()
        infoView.isHighlighted = isHighlighted
        infoView.isSelected = isSelected || isChecked
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        setupInfoView()
        contentView.addSubview(infoView)
    }
    
    func setupInfoView() {

    }
}
