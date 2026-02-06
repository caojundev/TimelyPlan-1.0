//
//  TPButtonActionsBar.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/15.
//

import Foundation
import UIKit

class TPButtonActionsBar: UIView {
    
    /// 动作按钮视图
    private(set) var actionsView: TPButtonActionsView
    
    convenience init(actions: [TPButtonAction]) {
        self.init(frame: .zero, actions: actions)
    }
    
    init(frame: CGRect, actions: [TPButtonAction]) {
        self.actionsView = TPButtonActionsView(actions: actions)
        if actions.count == 1 {
            self.actionsView.actionsCountPerRow = 1
        }
        
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.padding = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 16.0)
        addSubview(self.actionsView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        actionsView.frame = layoutFrame()
    }
    
    /// 仅按钮处响应事件
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return actionsView.frame.contains(point)
    }
}
