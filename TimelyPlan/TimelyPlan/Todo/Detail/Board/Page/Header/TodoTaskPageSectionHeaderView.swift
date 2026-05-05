//
//  TodoTaskPageSectionHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/15.
//

import Foundation
import UIKit

protocol TodoTaskPageSectionHeaderViewDelegate: AnyObject {
    
}

class TodoTaskPageSectionHeaderView: UICollectionReusableView {
    
    /// 代理对象
    weak var delegate: AnyObject?

    /// 区块索引
    var section: Int = 0
    
    /// 内容内间距
    var contentPadding: UIEdgeInsets = .zero {
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
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = layoutFrame()
        contentView.padding = contentPadding
        infoView.frame = contentView.layoutFrame()
    }
}
