//
//  TodoTaskBindViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/29.
//

import Foundation
import UIKit

class TodoTaskBindViewController: TPViewController,
                                   TodoTaskSelectViewDelegate {

    weak var delegate: TaskBindViewControllerDelegate?
    
    /// 选中任务回调
    var didSelectTask: ((TodoTask) -> Void)?
    
    /// 当前选中任务特征值
    private(set) var selectedFeature: TaskFeature?

    lazy var selectView: TodoTaskSelectView = {
        let view = TodoTaskSelectView(frame: view.bounds, style: .insetGrouped)
        view.placeholderProvider = viewModel.placeholderProvider
        view.delegate = self
        return view
    }()
    
    var viewModel = TodoTaskSelectViewModel()
    
    init(selectedFeature: TaskFeature?) {
        self.selectedFeature = selectedFeature
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(selectView)
        self.viewModel.onGroupsChanged = { [weak self] in
            self?.groupsChanged()
        }
        
        self.viewModel.loadGroups()
    }
    
    private func groupsChanged() {
        DispatchQueue.main.async {
            self.selectView.groups = self.viewModel.groups
            self.selectView.reloadData()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.selectView.frame = self.view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - TodoTaskSelectViewDelegate
    func todoTaskSelectView(_ view: TodoTaskSelectView, didSelectTask task: TodoTask) {
        TPImpactFeedback.impactWithSoftStyle()
        selectedFeature = task.feature
        delegate?.taskBindViewController(self, didSelectTask: task)
    }
    
    func todoTaskSelectView(_ view: TodoTaskSelectView, isSelectedTask task: TodoTask) -> Bool {
        return task.identifier == selectedFeature?.identifier
    }
}

