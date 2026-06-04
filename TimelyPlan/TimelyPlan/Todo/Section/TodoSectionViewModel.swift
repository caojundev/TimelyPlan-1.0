//
//  TodoSectionViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/3.
//

import Foundation

enum TodoSectionChange {
    case create(TodoSection)
    case update(TodoSection)
}

class TodoSectionViewModel: TodoSectionProcessorDelegate {
    
    /// 列表板块改变
    var onSectionsChanged: ((TodoSectionChange?) -> Void)?
    
    /// 列表包含的板块
    var sections: [TodoSection] = []
    
    private let list: TodoList?
    
    private(set) var state: TPListLoadingState = .initialLoading {
        didSet {
            placeholderProvider.state = state
        }
    }

    /// 占位视图
    private(set) lazy var placeholderProvider: TPLoadableListPlaceholderProvider = {
        let provider = TPLoadableListPlaceholderProvider()
        provider.state = .initialLoading
        provider.emptyTitle = resGetString("No Sections")
        provider.emptyImage = resGetImage("todo_section_80")
        return provider
    }()
    
    private let requestManager = TPRequestManager()
    
    init(list: TodoList?) {
        self.list = list
        todo.addUpdater(self, for: [.section])
    }
    
    func createSection(with name: String) {
        todo.createSection(with: name, in: list)
    }
    
    func updateSection(_ section: TodoSection, with name: String) {
        todo.updateSection(section, with: name)
    }
    
    func deleteSection(_ section: TodoSection) {
        todo.deleteSection(section)
    }
    
    func reorderSection(fromIndex: Int, toIndex: Int) -> Bool {
        guard todo.reorderSection(in: sections, fromIndex: fromIndex, toIndex: toIndex) else {
            return false
        }
        
        sections.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        return true
    }
    
    // MARK: -
    func loadSections(with change: TodoSectionChange? = nil, completion: (() -> Void)? = nil) {
        self.state = .loading
        let change = change
        let requestID = requestManager.executeRequest()
        fetchSections { [weak self] sections in
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                completion?()
                return
            }

            self.sections = sections ?? []
            self.state = .loaded
            self.onSectionsChanged?(change)
            completion?()
        }
    }
    
    private func fetchSections(completion: @escaping ([TodoSection]?) -> Void) {
        let sections = todo.getSections(for: list)
        completion(sections)
    }
    
    // MARK: - TodoSectionProcessorDelegate
    func didCreateTodoSection(_ section: TodoSection, in list: TodoList?) {
        loadSections(with: .create(section))
    }

    func didDeleteTodoSection(_ section: TodoSection) {
        loadSections()
    }
    
    func didUpdateTodoSection(_ section: TodoSection, with name: String) {
        loadSections(with: .update(section))
    }
}
