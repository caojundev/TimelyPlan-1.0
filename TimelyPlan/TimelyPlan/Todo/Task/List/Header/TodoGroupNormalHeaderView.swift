//
//  TodoGroupNormalHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/14.
//

import Foundation
import UIKit

protocol TodoGroupBaseHeaderViewDelegate: AnyObject {
    
    /// 点击展开 / 收起按钮
    func headerViewDidClickExpand(_ headerView: TodoGroupBaseHeaderView)
}

class TodoGroupBaseHeaderView: UITableViewHeaderFooterView {
    
    weak var delegate: TodoGroupBaseHeaderViewDelegate?
    
    var section: Int = -1
    
    var title: String? {
        get {
            return expandButton.title as? String
        }
        
        set {
            expandButton.title = newValue
            setNeedsLayout()
        }
    }
    
    /// 是否展开
    private(set) var isExpanded: Bool = true
    
    /// 展开按钮
    private(set) lazy var expandButton: TPChevronExpandButton = {
        let button = TPChevronExpandButton()
        button.padding = UIEdgeInsets(horizontal: 10.0, vertical: 10.0)
        button.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        button.cornerRadius = 8.0
        button.normalBackgroundColor = resGetColor(.insetGroupedTableCellBackgroundNormal)
        button.selectedBackgroundColor = resGetColor(.insetGroupedTableCellBackgroundSelected)
        button.addTarget(self,
                         action: #selector(clickExpand(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupContentSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupContentSubViews() {
        contentView.padding = UIEdgeInsets(horizontal: 0.0)
        contentView.addSubview(expandButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        expandButton.sizeToFit()
        expandButton.left = layoutFrame.minX
        expandButton.centerY = layoutFrame.midY
    }

    // MARK: - Public Methods
    func setExpanded(_ isExpanded: Bool, animated: Bool) {
        self.isExpanded = isExpanded
        expandButton.setExpanded(isExpanded, animated: animated)
        if animated {
            animateLayout(withDuration: 0.25)
        } else {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: - Event Response
    /// 点击展开或收起按钮
    @objc func clickExpand(_ button: UIButton) {
        delegate?.headerViewDidClickExpand(self)
    }
}


class TodoGroupNormalHeaderView: TodoGroupBaseHeaderView {
    
    var count: Int = 0 {
        didSet {
            if count != oldValue {
                countLabel.text = "\(count)"
            }
        }
    }
    
    private(set) lazy var countLabel: TPLabel = {
        let label = TPLabel()
        label.edgeInsets = UIEdgeInsets(horizontal: 10.0, vertical: 8.0)
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.textColor = resGetColor(.title)
        label.text = "\(count)"
        return label
    }()
    
    override func setupContentSubViews() {
        super.setupContentSubViews()
        contentView.addSubview(countLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        countLabel.layer.backgroundColor = expandButton.normalBackgroundColor?.cgColor
        countLabel.layer.cornerRadius = 8.0
        countLabel.sizeToFit()
        countLabel.centerY = layoutFrame.midY
        countLabel.right = layoutFrame.maxX
        let expandButtonMaxWidth = countLabel.left - layoutFrame.minX - 5.0
        if expandButton.width > expandButtonMaxWidth {
            expandButton.width = expandButtonMaxWidth
        }
    }
}
