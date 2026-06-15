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
                                      TPGroupCollectionViewDelegate {
    
    var selectedTimerID: String?
    
    var didSelectTimer: ((FocusTimerRepresentable) -> Void)?
    
    private let viewModel = FocusUserTimerViewModel()
    
    private lazy var selectView: FocusTimerSelectView = {
        let view = FocusTimerSelectView(frame: view.bounds)
        view.showSectionHeader = true
        view.delegate = self
        view.placeholderProvider = self.viewModel.placeholderProvider
        view.refreshHandler = { [weak self] in
            self?.handleRefresh()
        }
        
        return view
    }()
    
    lazy var defaultTimerGroup: FocusTimerGroup = {
        let group = FocusTimerGroup(identifier: FocusTimerGroupIdentifier.system.rawValue)
        group.timers = FocusRepository.allDefaultTimers()
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
        self.selectView.reloadData()
        self.viewModel.timersDidChange = { [weak self] change in
            self?.timersChanged(change)
        }
        
        self.viewModel.loadTimers()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.selectView.frame = view.bounds
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func handleRefresh() {
        self.viewModel.setNeedsRefresh()
        self.viewModel.loadTimers()
    }
    
    private func timersChanged(_ change: FocusUserTimerChange?) {
        var groups = [defaultTimerGroup]
        if let userTimers = viewModel.timers, userTimers.count > 0 {
            let group = FocusTimerGroup(identifier: FocusTimerGroupIdentifier.user.rawValue)
            group.name = resGetString("Custom")
            group.timers = userTimers
            groups.append(group)
        }
        
        DispatchQueue.main.async {
            self.selectView.groups = groups
            self.selectView.performUpdate()
        }
    }

    // MARK: - TPGroupCollectionViewDelegate
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
