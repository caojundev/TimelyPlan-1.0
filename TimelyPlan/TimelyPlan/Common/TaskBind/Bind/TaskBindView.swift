//
//  TaskBindView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/1.
//

import Foundation
import UIKit

class TaskBindView: UIView {
    
    /// 当前任务改变
    var didPickTask: ((TaskRepresentable?) -> Void)?
    
    /// 当前任务
    var taskFeature: TaskFeature? {
        didSet {
            updateTaskName(animated: true)
        }
    }

    /// 任务按钮
    private lazy var taskButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.titleConfig.font = BOLD_SYSTEM_FONT
        button.imagePosition = .right
        button.imageConfig.margins = UIEdgeInsets(value: 5.0)
        button.imageConfig.size = .size(4)
        button.addTarget(self,
                         action: #selector(didClickTask(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(taskButton)
        updateTaskName(animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = bounds.inset(by: UIEdgeInsets(horizontal: 10.0))
        taskButton.sizeToFit()
        if taskButton.width > layoutFrame.width {
            taskButton.width = layoutFrame.width
        }
        
        taskButton.alignCenter()
    }
    
    /// 更新任务名称
    private func updateTaskName(animated: Bool) {
        if let taskFeature = taskFeature {
            taskButton.image = taskFeature.typeImage
            taskButton.title = taskFeature.snapshotName ?? resGetString("Untitled")
        } else {
            taskButton.image = resGetImage("bind_16")
            taskButton.title = resGetString("Select Task")
        }
        
        if animated {
            animateLayout(withDuration: 0.25)
        } else {
            setNeedsLayout()
        }
    }
    
    /// 点击任务
    @objc func didClickTask(_ button: UIButton) {
        TPImpactFeedback.impactWithLightStyle()
        TaskBindViewController.show(with: taskFeature) { task in
            self.taskFeature = task?.feature
            self.didPickTask?(task)
        }
    }
    
}
