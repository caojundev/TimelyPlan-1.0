//
//  TodoStepInputToolbar.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/16.
//

import Foundation

class TodoStepInputToolbar: UIToolbar {
    
    // MARK: - Button Properties
    
    lazy var addPreviousStepButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: resGetImage("todo_task_step_addPrevious_24"),
            style: .done,
            target: self,
            action: #selector(clickAddPreviousStep(_:))
        )
        return button
    }()
    
    lazy var addNextStepButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: resGetImage("todo_task_step_addNext_24"),
            style: .done,
            target: self,
            action: #selector(clickAddNextStep(_:))
        )
        return button
    }()
    
    lazy var addSubstepButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: resGetImage("todo_task_step_addSubstep_24"),
            style: .done,
            target: self,
            action: #selector(clickAddSubstep(_:))
        )
        return button
    }()
    
    lazy var dismissButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: resGetImage("keyboard_dismiss_24"),
            style: .done,
            target: self,
            action: #selector(clickDismiss(_:))
        )
        return button
    }()
    
    // MARK: - Callback Closures
    
    var onAddPreviousStep: (() -> Void)?
    var onAddNextStep: (() -> Void)?
    var onAddSubstep: (() -> Void)?
    var onDismiss: (() -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupToolbar()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupToolbar()
    }
    
    convenience init() {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        self.init(frame: frame)
    }
    
    // MARK: - Setup
    
    private func setupToolbar() {
        tintColor = resGetColor(.title)
        
        let flexibleSpace1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let flexibleSpace2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let flexibleSpace3 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        items = [
            addPreviousStepButton,
            flexibleSpace1,
            addNextStepButton,
            flexibleSpace2,
            addSubstepButton,
            flexibleSpace3,
            dismissButton
        ]
    }
    
    // MARK: - Button Actions
    
    @objc private func clickAddPreviousStep(_ sender: UIBarButtonItem) {
        onAddPreviousStep?()
    }
    
    @objc private func clickAddNextStep(_ sender: UIBarButtonItem) {
        onAddNextStep?()
    }
    
    @objc private func clickAddSubstep(_ sender: UIBarButtonItem) {
        onAddSubstep?()
    }
    
    @objc private func clickDismiss(_ sender: UIBarButtonItem) {
        onDismiss?()
    }
}
