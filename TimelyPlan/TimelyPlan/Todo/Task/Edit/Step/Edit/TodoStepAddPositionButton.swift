//
//  TodoStepPositionButton.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/6.
//

import Foundation

enum TodoStepAddPosition {
    case top
    case bottom
}

class TodoStepPositionButton: TPDefaultButton {
    
    var position: TodoStepAddPosition = .bottom {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = .zero
        self.image = resGetImage("todo_task_step_addPosition_24")
        self.imageConfig.color = resGetColor(.title)
    }
    
     required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        let imageView = self.imageTitleView.imageView
        imageView.transform = .identity
        super.layoutSubviews()
        if position == .top {
            imageView.transform = .init(rotationAngle: -CGFloat.pi)
        }
    }
    
    func setPosition(_ position: TodoStepAddPosition, animated: Bool) {
        self.position = position
        if animated {
            animateLayout(withDuration: 0.25)
        }
    }
}
