//
//  FocusTimerInfoMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/24.
//

import Foundation
import UIKit

class FocusTimerInfoMenuController: FocusUserTimerMenuController {

    override func allowMenuActionTypes() -> [FocusUserTimerMenuType] {
        return super.allowMenuActionTypes()
    }
    
    private func menuViewController() -> FocusTimerInfoSheetMenuViewController? {
        let menuItems = menuItems()
        guard menuItems.count > 0 else {
            return nil
        }
        
        let menuVC = FocusTimerInfoSheetMenuViewController(timer: timer,
                                                           menuItems: menuItems)
        menuVC.didSelectMenuAction = { action in
            guard let type = FocusUserTimerMenuType(rawValue: action.identifier) else {
                return
            }

            self.didSelectMenuActionType?(type)
        }
        
        return menuVC
    }
    
    func showSheetMenu() {
        guard let menuVC = menuViewController() else {
            return
        }
        
        if let sheet = menuVC.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        
        menuVC.show()
    }
}

class FocusTimerInfoSheetMenuViewController: TPSheetMenuViewController {
    
    private let infoViewHeight = 70.0

    private let indicatorSize = CGSize(width: 6.0, height: 36.0)
    
    private let infoView = TPColorInfoView()
    
    /// 任务
    let timer: FocusTimer
    
    init(timer: FocusTimer, menuItems: [TPMenuItem]) {
        self.timer = timer
        super.init(menuItems: menuItems)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(infoView)
        updateInfo()
        actionsBarHeight = 80.0
        setupActionsBar(actions: [doneAction])
        actionsBar?.backgroundColor = themeBackgroundColor
        actionsBar?.padding = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 15.0, right: 20.0)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.bounds.inset(by: UIEdgeInsets(horizontal: 20.0))
        infoView.width = layoutFrame.width
        infoView.height = infoViewHeight
        infoView.top = titleLabel.bottom + titleMargins.bottom
        infoView.left = layoutFrame.minX
    }
    
    override func tableViewFrame() -> CGRect {
        var frame = super.tableViewFrame()
        frame.origin.y = frame.origin.y + infoViewHeight
        frame.size.height = frame.size.height - infoViewHeight
        return frame
    }
    
    private func updateInfo() {
        infoView.colorConfig = .withColor(timer.color, size: indicatorSize)
        infoView.title = timer.displayName
        infoView.subtitle = timer.timerDescription
    }
}
