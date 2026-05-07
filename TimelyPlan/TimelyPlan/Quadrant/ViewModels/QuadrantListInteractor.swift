//
//  QuadrantListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/7.
//

import Foundation

class QuadrantListInteractor: TodoListInteractor,
                              SettingAgentObserver,
                              TPMidnightUpdatable {

    var didChangeSetting: ((QuadrantSetting.Key) -> Void)?
    
    var titlePosition: QuadrantTitlePosition {
        let layout = QuadrantSetting.shared.layout
        return layout.getTitlePosition()
    }
    
    override var showCompleted: Bool {
        return QuadrantSetting.shared.showCompleted
    }
    
    override var showDetail: Bool {
        return QuadrantSetting.shared.showDetail
    }
    
    var quadrant: Quadrant {
        return quadrantConfiguration.quadrant
    }
    
    var filterRule: TodoFilterRule {
        return quadrantConfiguration.filterRule
    }
    
    var matchingQuickAddTask: TodoQuickAddTask? {
        return configuration.quickAddTask()
    }
    
    private var quadrantConfiguration: QuadrantListConfiguration{
       return configuration as! QuadrantListConfiguration
    }
    
    override init(configuration: TodoListConfiguration) {
        super.init(configuration: configuration)
        self.placeholderProvider.emptyImage = quadrant.placeholderImage
        self.placeholderProvider.emptyTitle = resGetString("No Tasks")
        self.placeholderProvider.emptyTitleColor = .systemGray5
        self.placeholderProvider.emptyTitleFont = BOLD_SMALL_SYSTEM_FONT
        QuadrantSetting.shared.addObserver(self)
        TPMidnightScheduler.shared.addUpdater(self)
        todo.addUpdater(self)
    }

    override func fetchTasks(completion: @escaping ([TodoTask]?) -> Void) {
        todo.fetchTasks(filterRule: filterRule,
                        showCompleted: showCompleted,
                        completion: completion)
    }

    override func title() -> TextRepresentable? {
        return quadrant.title
    }

    // MARK: - SettingAgentObserver
    func settingAgentDidChangeValue(for keyName: String) {
        guard let settingKey = QuadrantSetting.Key(name: keyName) else {
            return
        }
        
        switch settingKey {
        case .showCompleted:
            didChangeShowCompleted()
        case .customRules:
            didChangeCustomRules()
        default:
            break
        }
        
        didChangeSetting?(settingKey)
    }
    
    private func didChangeShowCompleted() {
        setNeedsRefresh()
        loadGroups()
    }
    
    private func didChangeCustomRules() {
        let rule = QuadrantSetting.shared.filterRule(for: quadrant)
        guard filterRule != rule else {
            return
        }
        
        quadrantConfiguration.updateFilterRule(rule)
        setNeedsRefresh()
        loadGroups()
    }
    
    // MARK: - TPMidnightUpdatable
    func updateAtMidnight() {
        guard filterRule.dateFilterValue != nil else {
            return
        }
        
        self.setNeedsRefresh()
        self.loadGroups()
    }
}
