//
//  QuadrantHomeListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/8.
//

import Foundation

class QuadrantHomeListInteractor: QuadrantListInteractor,
                                    SettingAgentObserver {

    var didChangeSetting: ((QuadrantSetting.Key) -> Void)?
    
    var titlePosition: QuadrantTitlePosition {
        let layout = QuadrantSetting.shared.layout
        return layout.getTitlePosition()
    }
    
    override var groupType: TodoGroupType {
        return .default
    }
    
    override var sort: TodoSort {
        return TodoSort(type: .creationDate, order: .descending)
    }
    
    override var showCompleted: Bool {
        return QuadrantSetting.shared.showCompleted
    }
    
    override var showDetail: Bool {
        return QuadrantSetting.shared.showDetail
    }
  
    override init(configuration: TodoListConfiguration) {
        super.init(configuration: configuration)
        self.placeholderProvider.emptyImage = quadrant.placeholderImage
        self.placeholderProvider.emptyTitle = resGetString("No Tasks")
        self.placeholderProvider.emptyTitleColor = .systemGray4
        self.placeholderProvider.emptyTitleFont = BOLD_SMALL_SYSTEM_FONT
        QuadrantSetting.shared.addObserver(self)
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
        let newRule = QuadrantSetting.shared.filterRule(for: quadrant)
        guard self.filterRule != newRule else {
            return
        }
        
        updateFilterRule(newRule)
        setNeedsRefresh()
        loadGroups()
    }
}
