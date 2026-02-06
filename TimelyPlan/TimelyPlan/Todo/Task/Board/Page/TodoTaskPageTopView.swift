//
//  TodoTaskPageTopView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/17.
//

import Foundation
import UIKit

protocol TodoTaskPageTopViewDelegate: AnyObject {
    
    /// 点击更多按钮
    func taskTopViewDidClickMore(_ topView: TodoTaskPageTopView)
}

class TodoTaskPageTopView: UIView {
    
    /// 代理对象
    weak var delegate: TodoTaskPageTopViewDelegate?
    
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
    
    /// 更多按钮
    private(set) lazy var moreButton: TPDefaultButton = {
        let image = resGetImage("ellipsis_24")
        let button = TPDefaultButton.button(with: image)
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
        self.padding = UIEdgeInsets(horizontal: 4.0)
        self.backgroundColor = .systemBackground
        infoView.rightAccessoryView = moreButton
        infoView.rightAccessorySize = .mini
        addSubview(infoView)
        addSeparator(position: .bottom)
        updateStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = layoutFrame()
    }
    
    private func updateStyle() {
        if !isSeparatorHidden {
            separatorView?.isHidden = false
        } else {
            separatorView?.isHidden = true
        }
    }
    
    // MARK: - Event Response
    /// 点击更多
    func clickMore() {
        delegate?.taskTopViewDidClickMore(self)
    }
}
