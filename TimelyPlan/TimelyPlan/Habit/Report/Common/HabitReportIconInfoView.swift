//
//  HabitReportIconInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/17.
//

import Foundation

class HabitReportIconInfoView: UIView {
    
    var icon: TPIcon? {
        get {
            return iconView.icon
        }
        
        set {
            iconView.icon = newValue
        }
    }
    
    var title: TextRepresentable? {
        get {
            return titleView.title
        }
        
        set {
            titleView.title = newValue
        }
    }
    
    /// 图标尺寸
    var iconSize = CGSize.size(8) {
        didSet {
            if iconSize != oldValue {
                setNeedsLayout()
            }
        }
    }

    /// 任务图标视图
    private(set) lazy var iconView: TPIconView = {
        let view = TPIconView()
        view.borderWidth = 0.0
        view.placeholderCharacter = "C"
        return view
    }()
    
    /// 信息视图
    private(set) lazy var titleView: TPInfoView = {
        let view = TPInfoView()
        view.padding = UIEdgeInsets(left: 2.0)
        view.titleConfig.textAlignment = .left
        view.titleConfig.font = SMALL_SYSTEM_FONT
        view.titleConfig.numberOfLines = 2
        return view
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(iconView)
        addSubview(titleView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        iconView.size = iconSize
        iconView.left = layoutFrame.minX
        iconView.centerY = layoutFrame.midY
        iconView.cornerRadius = iconSize.halfHeight
        
        titleView.width = layoutFrame.width - iconSize.width
        titleView.height = layoutFrame.height
        titleView.left = iconView.right
        titleView.top = layoutFrame.minY
    }
}
