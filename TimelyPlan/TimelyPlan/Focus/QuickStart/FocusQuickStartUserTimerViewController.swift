//
//  FocusQuickStartUserTimerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/26.
//

import Foundation
import UIKit

class FocusQuickStartUserTimerViewController: TPViewController,
                                              TPLoadableGroupCollectionViewDelegate {

    var didSelectTimer: ((FocusTimerRepresentable) -> Void)?
    
    private lazy var selectView: FocusTimerSelectView = {
        let view = FocusTimerSelectView(frame: view.bounds)
        view.delegate = self
        view.listPlaceholderProvider.emptyImage = resGetImage("focus_placeholder_noTimer_80")
        view.listPlaceholderProvider.emptyTitle = resGetString("No Timer")
        return view
    }()
    
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
            guard let timers = timers, timers.count > 0 else {
                completion(nil)
                return
            }

            let group = FocusTimerGroup(identifier: "UserTimerGroup")
            group.timers = timers
            completion([group])
        }
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let timer = collectionView.item(at: indexPath) as? FocusTimer else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        didSelectTimer?(timer)
    }
}
