//
//  FocusStatsOverallViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/4.
//

import Foundation

class FocusStatsOverallViewController: FocusStatsBaseViewController,
                                       SettingAgentObserver {

    /// 更多菜单按钮
    private lazy var moreBarButtonItem: FocusStatsOverallMoreBarButtonItem = {
        let item = FocusStatsOverallMoreBarButtonItem()
        item.didSelectType = { [weak self] type in
            self?.didSelectMoreMenuType(type)
        }
        
        return item
    }()
    
    init(type: StatsType = .week, allowTypes: [StatsType] = StatsType.allCases, date: Date = .now) {
        super.init(type: type, allowTypes: allowTypes, date: date)
        self.canSelectDetailGroupType = true
        self.allowDetailGroupTypes = FocusStatsDetailGroupType.allCases
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = moreBarButtonItem
        FocusSetting.shared.addObserver(self, forKey: .isOverallStatsShowArchived)
    }

    private func didSelectMoreMenuType(_ type: FocusStatsOverallMoreMenuType) {
        switch type {
        case .showArchived:
            let showArchived = !FocusSetting.shared.isOverallStatsShowArchived
            FocusSetting.shared.isOverallStatsShowArchived = showArchived
        }
    }
    
    // MARK: - SettingAgentObserver
    func settingAgentDidChangeValue(for keyName: String) {
        if keyName == FocusSetting.Key.isOverallStatsShowArchived.name {
            /// 重新加载数据
            let vc = self.contentViewController as? FocusStatsContentViewController
            vc?.reloadData()
        }
    }
}
