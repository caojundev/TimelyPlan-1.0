//
//  FocusQuickStartUserTimerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/26.
//

import Foundation
import UIKit

class FocusQuickStartUserTimerViewController: TPViewController,
                                              TPGroupCollectionViewDelegate {

    var didSelectTimer: ((FocusTimerRepresentable) -> Void)?
    
    private let viewModel = FocusUserTimerViewModel()
    
    private lazy var selectView: FocusTimerSelectView = {
        let view = FocusTimerSelectView(frame: view.bounds)
        view.delegate = self
        view.placeholderProvider = self.viewModel.placeholderProvider
        view.refreshHandler = { [weak self] in
            self?.handleRefresh()
        }
        
        return view
    }()
    
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
        let group = FocusTimerGroup(identifier: "UserTimerGroup")
        group.timers = self.viewModel.timers
        DispatchQueue.main.async {
            self.selectView.groups = [group]
            self.selectView.performUpdate()
        }
    }
    
    // MARK: - TPGroupCollectionViewDelegate
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let timer = collectionView.item(at: indexPath) as? FocusTimer else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        didSelectTimer?(timer)
    }
}
