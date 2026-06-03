//
//  TodoTaskPageAddFooterView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/1.
//

import Foundation
import UIKit

protocol TodoTaskPageAddFooterViewDelegate: AnyObject {
    
    /// 点击添加
    func todoTaskPageAddFooterViewDidClickAdd(_ footerView: TodoTaskPageAddFooterView)
}

class TodoTaskPageAddFooterView: UICollectionReusableView {
    
    /// 代理对象
    weak var delegate: TodoTaskPageAddFooterViewDelegate?
   
    /// 添加视图
    private lazy var addView: TodoTaskPageAddView = {
        let view = TodoTaskPageAddView(frame: .zero)
        view.didClickAdd = { [weak self] in
            guard let self = self else { return }
            self.delegate?.todoTaskPageAddFooterViewDidClickAdd(self)
        }

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupContentSubviews()
    }

    func setupContentSubviews() {
        addSubview(addView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        addView.frame = bounds
    }
}
