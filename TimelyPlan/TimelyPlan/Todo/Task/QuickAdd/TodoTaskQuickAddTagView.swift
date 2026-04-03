//
//  TodoTaskQuickAddTagView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/21.
//

import Foundation
import UIKit

class TodoTaskQuickAddTagView: TodoTaskEditDetailView {
    
    var tags: Set<TodoTag>? {
        didSet {
            self.attributedInfo = tags?.attributedOrderedTagsInfo()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 10.0, vertical: 2.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
