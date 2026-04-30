//
//  HabitActiveTaskViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/30.
//

import Foundation

enum HabitTaskChange {
    case create(HabitTask)
    case update(HabitTask)
    case delete(HabitTask)
    case archive(HabitTask)
}

class HabitActiveTaskViewModel: HabitTaskProcessorDelegate {
    
    private(set) var tasks: [HabitTask]?
    
    var tasksDidChange: ((HabitTaskChange?) -> Void)?
    
    private(set) var state: TPListLoadingState = .initialLoading {
        didSet {
            self.placeholderProvider.state = state
        }
    }
    
    private var needsRefresh = true

    private let requestManager = TPRequestManager()
    
    var placeholderProvider = TPLoadableListPlaceholderProvider()
    
    init() {
        self.placeholderProvider.state = self.state
        self.setupPlaceholderProvider()
        habit.addUpdater(self, for: [.task])
    }

    func setupPlaceholderProvider() {
        self.placeholderProvider.emptyImage = resGetImage("habit_plceholder_task_80")
        self.placeholderProvider.emptyTitle = resGetString("Tap + to create a new habit")
    }
    
    func setNeedsRefresh(_ refresh: Bool = true) {
        self.needsRefresh = refresh
    }

    // MARK: -
    func loadTasks(with change: HabitTaskChange? = nil) {
        let change = change
        let requestID = requestManager.executeRequest()
        loadTasksIfNeeded {[weak self] tasks in
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                return
            }

            self.tasks = tasks
            self.setNeedsRefresh(false)
            self.state = .loaded
            self.tasksDidChange?(change)
        }
    }
    
    private func loadTasksIfNeeded(completion: @escaping ([HabitTask]?) -> Void) {
        guard self.needsRefresh else {
            completion(self.tasks)
            return
        }
        
        fetchTasks(completion: completion)
    }

    func fetchTasks(completion: @escaping ([HabitTask]?) -> Void) {
        habit.fetchActiveTasks(completion: completion)
    }
    
    // MARK: - HabitTaskProcessorDelegate
    func didCreateHabitTask(_ task: HabitTask) {
        setNeedsRefresh()
        loadTasks(with: .create(task))
    }

    func didUpdateHabitTask(_ task: HabitTask) {
        setNeedsRefresh()
        loadTasks(with: .update(task))
    }
    
    func didDeleteHabitTask(_ task: HabitTask) {
        setNeedsRefresh()
        loadTasks(with: .delete(task))
    }
    
    func didChangeArchivedState(for task: HabitTask) {
        setNeedsRefresh()
        loadTasks(with: .archive(task))
    }
}

class HabitArchivedTaskViewModel: HabitActiveTaskViewModel {
    
    override func setupPlaceholderProvider() {
        self.placeholderProvider.emptyImage = resGetImage("archivedList_80")
        self.placeholderProvider.emptyTitle = resGetString("No Archived Habit")
    }
    
    override func fetchTasks(completion: @escaping ([HabitTask]?) -> Void) {
        habit.fetchArchivedTasks(completion: completion)
    }
}
