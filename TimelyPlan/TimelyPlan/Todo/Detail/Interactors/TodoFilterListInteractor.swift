//
//  TodoFilterListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/20.
//

import Foundation

class TodoFilterListInteractor: TodoListInteractor,
                                TodoFilterProcessorDelegate {
    
    var filter: TodoFilter {
        return listConfiguration.filter
    }
    
    var listConfiguration: TodoFilterListConfiguration {
       return configuration as! TodoFilterListConfiguration
    }
    
    override init(configuration: TodoListConfiguration) {
        super.init(configuration: configuration)
        todo.addUpdater(self, for: [.filter])
    }
    
    override func fetchTasks(completion: @escaping ([TodoTask]?) -> Void) {
        todo.fetchTasks(filter: self.filter, showCompleted: self.state.showCompleted, completion: completion)
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
    
    // MARK: - TodoFilterProcessorDelegate
    func didUpdateTodoFilter(_ filter: TodoFilter) {
        let oldFilter = listConfiguration.filter
        guard filter.identifier == oldFilter.identifier else {
            return
        }
        
        /// 获取更新后的过滤器
        if let newFilter = todo.getFilter(of: filter.identifier), !newFilter.isEqual(oldFilter) {
            self.listConfiguration.updateFilter(newFilter)
            self.didChangeListInfo?()
        }
    
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
}
