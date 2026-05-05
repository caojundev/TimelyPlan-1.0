//
//  TodoTaskPageHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/17.
//

import Foundation
import UIKit

protocol TodoTaskPageHeaderViewDelegate: AnyObject {
    
    /// 点击重新安排
    func taskHeaderViewDidClickReschedule(_ headerView: TodoTaskPageHeaderView)
    
    /// 点击更多按钮
    func taskHeaderViewDidClickMore(_ headerView: TodoTaskPageHeaderView)
}

class TodoTaskPageHeaderView: UIView {
    
    /// 代理对象
    weak var delegate: TodoTaskPageHeaderViewDelegate?
    
    /// 分割线是否隐藏
    var isSeparatorHidden: Bool = true {
        didSet {
            if isSeparatorHidden != oldValue {
                updateStyle()
            }
        }
    }
    
    /// 标题
    var title: TextRepresentable? {
        get {
            return infoView.title
        }
        
        set {
            infoView.title = newValue
        }
    }
    
    /// 信息视图
    private let infoView = TPInfoView()
    
    /// 重新安排按钮
    private var rescheduleButton: TPDefaultButton?
    
    /// 显示重新安排按钮
    var showRescheduleButton: Bool = false {
        didSet {
            guard showRescheduleButton != oldValue else {
                return
            }
            
            if showRescheduleButton {
                addRescheduleButton()
            } else {
                removeRescheduleButton()
            }
        }
    }
    
    /// 更多按钮
    private(set) lazy var moreButton: TPDefaultButton = {
        let image = resGetImage("ellipsis_24")
        let button = TPDefaultButton.button(with: image)
        button.isHidden = true
        button.didClickHandler = { [weak self] in
            self?.clickMore()
        }
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        self.padding = .zero
        addSubview(infoView)
        addSeparator(position: .bottom)
        updateStyle()
    }
    
    private func addRescheduleButton() {
        guard rescheduleButton == nil else {
            return
        }
        
        let button = TPDefaultButton()
        button.title = resGetString("Reschedule")
        button.padding = UIEdgeInsets(horizontal: 10.0, vertical: 8.0)
        button.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        button.cornerRadius = 8.0
        button.titleConfig.textColor = .white
        button.normalBackgroundColor = .primary
        button.addTarget(self,
                         action: #selector(clickReschedule(_:)),
                         for: .touchUpInside)
        self.infoView.rightAccessoryView = button
        self.infoView.rightAccessorySize = button.sizeThatFits(.unlimited)
        self.rescheduleButton = button
    }
    
    private func removeRescheduleButton() {
        guard rescheduleButton != nil else {
            return
        }
        
        self.infoView.rightAccessoryView = nil
        self.infoView.rightAccessorySize = .zero
        self.rescheduleButton = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        infoView.frame = layoutFrame
    }
    
    private func updateStyle() {
        if !isSeparatorHidden {
            separatorView?.isHidden = false
        } else {
            separatorView?.isHidden = true
        }
    }
    
    // MARK: - Event Response
    func clickMore() {
        delegate?.taskHeaderViewDidClickMore(self)
    }
    
    @objc func clickReschedule(_ button: UIButton) {
        delegate?.taskHeaderViewDidClickReschedule(self)
    }
    
}
