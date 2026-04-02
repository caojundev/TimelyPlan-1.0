//
//  TodoHomeToolView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/29.
//

import Foundation
import UIKit

class TodoHomeToolView: TPToolbar {
    
    /// 点击添加列表
    var didClickAddList: (() -> Void)?

    /// 添加列表
    lazy var addListButtonItem: TPBarButtonItem = {
        let image = resGetImage("todo_list_add_24")
        let item = TPBarButtonItem(image: image) {[weak self] _ in
            TPImpactFeedback.impactWithSoftStyle()
            self?.didClickAddList?()
        }
        
        return item
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.buttonItems = [.flexibleSpaceButtonItem,
                            addListButtonItem]
        self.addSeparator(position: .top)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
