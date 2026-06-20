//
//  TodoFilterListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/20.
//

import Foundation

class TodoFilterListInteractor: TodoListInteractor,
                                TodoFilterProcessorDelegate,
                                TPMidnightUpdatable {
    
    var filter: TodoFilter {
        return listConfiguration.filter
    }
    
    var listConfiguration: TodoFilterListConfiguration {
       return configuration as! TodoFilterListConfiguration
    }
    
    override init(configuration: TodoListConfiguration) {
        super.init(configuration: configuration)
        self.placeholderProvider.emptyImage = resGetImage("todo_filter_80")
        self.placeholderProvider.emptyTitle = resGetString("The current filter has no tasks")
        TPMidnightScheduler.shared.addUpdater(self)
        TodoRepository.addUpdater(self, for: [.filter])
    }
    
    override func fetchTasks(completion: @escaping ([TodoTask]?) -> Void) {
        TodoRepository.fetchTasks(filter: self.filter,
                        showCompleted: self.listOptionState.showCompleted,
                        completion: completion)
    }

    override func title() -> TextRepresentable? {
        let tagName = self.filter.name ?? resGetString("Untitled")
        if let image = resGetImage("todo_home_filter_24") {
            let title: ASAttributedString
            title = .string(image: image,
                            imageSize: .size(4),
                            imageColor: self.filter.color,
                            trailingText: tagName,
                            separator: " ")
            return title
        }
        
        return tagName
    }
    
    // MARK: - TPMidnightUpdatable
    func updateAtMidnight() {
        guard filter.rule?.dateFilterValue != nil else {
            return
        }
        
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    // MARK: - TodoFilterProcessorDelegate
    func didChangeRemoteTodoFilter(with results: EntityChangeResults<TodoFilter>?) {
        guard let newFilter = TodoRepository.getFilter(of: filter.identifier) else {
            return
        }
        
        listConfiguration.updateFilter(newFilter)
        didChangeListInfo?()
        setNeedsRefresh()
        loadGroups()
    }
    
    func didUpdateTodoFilter(_ filter: TodoFilter, with editingFilter: TodoEditingFilter) {
        let oldFilter = listConfiguration.filter
        guard filter.identifier == oldFilter.identifier else {
            return
        }
        
        /// 获取更新后的过滤器
        filter.update(with: editingFilter)
        listConfiguration.updateFilter(filter)
        didChangeListInfo?()
        setNeedsRefresh()
        loadGroups()
    }
    
}
