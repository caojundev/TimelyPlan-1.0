//
//  HabitTaskBindViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/27.
//

import Foundation
import UIKit

class HabitTaskBindViewController: TPViewController,
                                   TPGroupCollectionViewDelegate {

    weak var delegate: TaskBindViewControllerDelegate?
    
    /// 当前选中任务标识
    private(set) var selectedFeature: TaskFeature?

    lazy var cellStyle: TPCollectionCellStyle = {
        let style = TPCollectionCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .secondarySystemFill
        style.cornerRadius = 12.0
        return style
    }()
    
    lazy var listView: TPGroupCollectionView = {
        let view = TPGroupCollectionView(frame: view.bounds)
        view.preferredItemHeight = 64.0
        view.delegate = self
        view.refreshHandler = { [weak self] in
            self?.handleRefresh()
        }
        
        return view
    }()
    
    var viewModel = HabitActiveTaskViewModel()
    
    init(selectedFeature: TaskFeature?) {
        self.selectedFeature = selectedFeature
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.listView)
        let placeholderProvider = viewModel.placeholderProvider
        placeholderProvider.emptyTitle = resGetString("No Habit")
        self.listView.placeholderProvider = placeholderProvider
        self.viewModel.tasksDidChange = { [weak self] change in
            self?.tasksChanged(change)
        }
        
        self.viewModel.loadTasks()
    }
    
    private func handleRefresh() {
        self.viewModel.setNeedsRefresh()
        self.viewModel.loadTasks()
    }
    
    private func tasksChanged(_ change: HabitTaskChange?) {
        let group = HabitTaskGroup(identifier: "Tasks")
        group.tasks = self.viewModel.tasks
        DispatchQueue.main.async {
            self.listView.groups = [group]
            self.listView.reloadData()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.listView.frame = self.view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - TPGroupCollectionViewDelegate
    func groupCollectionView(_ collectionView: TPGroupCollectionView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return HabitTaskBindCell.self
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! HabitTaskBindCell
        cell.cellStyle = cellStyle
        cell.habitTask = collectionView.item(at: indexPath) as? HabitTask
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool {
        guard let task = collectionView.item(at: indexPath) as? HabitTask else {
            return false
        }
        
        return task.identifier == selectedFeature?.identifier
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let task = collectionView.item(at: indexPath) as? HabitTask else {
            return
        }
    
        TPImpactFeedback.impactWithSoftStyle()
        selectedFeature = task.feature
        delegate?.taskBindViewController(self, didSelectTask: task)
        collectionView.updateCheckmarks()
    }
}

