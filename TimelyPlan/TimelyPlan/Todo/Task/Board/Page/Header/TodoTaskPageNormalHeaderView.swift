//
//  TodoTaskPageNormalHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/15.
//

import Foundation
import UIKit

protocol TodoTaskPageNormalHeaderViewDelegate: AnyObject {
    
    /// 点击展开 / 收起按钮
    func taskPageHeaderViewDidClickExpand(_ headerView: TodoTaskPageNormalHeaderView)
}

class TodoTaskPageNormalHeaderView: UICollectionReusableView {
    
    /// 代理对象
    weak var delegate: AnyObject?

    /// 区块索引
    var section: Int = 0
    
    /// 内容内间距
    var contentPadding: UIEdgeInsets = UIEdgeInsets(horizontal: 4.0) {
        didSet {
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

    /// 是否已展开
    var isExpanded: Bool {
        get {
            return expandButton.isExpanded
        }
        
        set {
            expandButton.isExpanded = newValue
        }
    }
    
    /// 数目
    var count: Int? {
        didSet {
            guard count != oldValue else {
                return
            }
            
            if let count = count {
                infoView.valueConfig = .valueText("\(count)")
            } else {
                infoView.valueConfig = nil
            }
        }
    }
    
    /// 信息视图
    private(set) var infoView = TPInfoTextValueView()
    
    /// 展开按钮
    private let expandButtonSize: CGSize = .mini
    private lazy var expandButton: TPChevronExpandButton = {
        let button = TPChevronExpandButton()
        button.hitTestEdgeInsets = UIEdgeInsets(value: -12.0)
        button.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        button.image = resGetImage("chevron_right_16")
        button.imageConfig.size = .size(4)
        button.addTarget(self, action: #selector(clickExpand(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 内容视图
    let contentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupContentSubviews()
    }

    func setupContentSubviews() {
        addSubview(contentView)
        contentView.addSubview(infoView)
        contentView.addSubview(expandButton)
        expandButton.isExpanded = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        contentView.padding = contentPadding
        
        let layoutFrame = contentView.layoutFrame()
        expandButton.size = expandButtonSize
        expandButton.right = layoutFrame.maxX
        expandButton.centerY = layoutFrame.midY
        
        infoView.width = layoutFrame.width - expandButtonSize.width
        infoView.height = layoutFrame.height
        infoView.origin = layoutFrame.origin
    }
    
    // MARK: - Event Response
    
    @objc private func clickExpand(_ button: UIButton) {
        if let delegate = delegate as? TodoTaskPageNormalHeaderViewDelegate{
            delegate.taskPageHeaderViewDidClickExpand(self)
        }
    }
    
    func setExpanded(_ expanded: Bool, animated: Bool) {
        expandButton.setExpanded(expanded, animated: animated)
    }
}
