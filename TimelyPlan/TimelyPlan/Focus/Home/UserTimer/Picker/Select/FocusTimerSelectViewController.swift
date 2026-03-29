//
//  FocusTimerSelectViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/30.
//

import Foundation

enum FocusTimerGroupIdentifier: String {
    case system
    case user
}

class FocusTimerSelectViewController: TPViewController,
                                      TPLoadableGroupCollectionViewDelegate {
    
    var selectedTimerID: String?
    
    var didSelectTimer: ((FocusTimerRepresentable) -> Void)?
    
    private lazy var selectView: FocusTimerSelectView = {
        let view = FocusTimerSelectView(frame: view.bounds)
        view.showSectionHeader = true
        view.delegate = self
        view.listPlaceholderProvider.emptyImage = resGetImage("focus_placeholder_noTimer_80")
        view.listPlaceholderProvider.emptyTitle = resGetString("No Timer")
        return view
    }()
    
    lazy var defaultTimerGroup: FocusTimerGroup = {
        let group = FocusTimerGroup(identifier: FocusTimerGroupIdentifier.system.rawValue)
        group.timers = focus.allDefaultTimers()
        return group
    }()
    
    init(selectedTimerID: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.selectedTimerID = selectedTimerID
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.selectView)
        self.selectView.asyncReloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.selectView.frame = view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    // MARK: - TPLoadableGroupCollectionViewDelegate
    func loadableGroupCollectionView(_ collectionView: TPLoadableGroupCollectionView, forceRefresh: Bool, fetchTaskGroups completion: @escaping ([GroupRepresentable]?) -> Void) {
        focus.fetchActiveTimers { timers in
            var groups = [self.defaultTimerGroup]
            if let timers = timers, timers.count > 0 {
                let userTimerGroup = FocusTimerGroup(identifier: FocusTimerGroupIdentifier.user.rawValue)
                userTimerGroup.name = resGetString("Custom")
                userTimerGroup.timers = timers
                groups.append(userTimerGroup)
            }
            
            completion(groups)
        }
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let timer = collectionView.item(at: indexPath) as? FocusTimerRepresentable else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        self.selectedTimerID = timer.identifier
        self.selectView.updateCheckmarks()
        self.didSelectTimer?(timer)
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool {
        guard let selectedTimerID = self.selectedTimerID,
              let timer = collectionView.item(at: indexPath) as? FocusTimerRepresentable else {
            return false
        }
        
        return timer.identifier == selectedTimerID
    }
    
}
