//
//  FocusStatsSpecificViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/26.
//

import Foundation
import UIKit

class FocusStatsSpecificViewController: FocusStatsBaseViewController,
                                        FocusSessionProcessorDelegate {
    /// 信息视图间距
    let infoViewEdgeMargins = UIEdgeInsets(value: 10.0)
    
    let infoViewHeight = 80.0
    
    /// 信息视图
    var infoView: FocusStatsInfoView!

    init(timer: FocusTimer) {
        super.init(type: .week, allowTypes: StatsType.allCases, date: .now)
        self.timer = timer
        self.setupInfoView(timer: timer)
        self.canSelectDetailGroupType = false
        self.allowDetailGroupTypes = [.task]
        focus.addUpdater(self, for: [.session])
    }
    
    init(task: TaskRepresentable) {
        super.init(type: .week, allowTypes: StatsType.allCases, date: .now)
        self.task = task
        self.setupInfoView(task: task)
        self.canSelectDetailGroupType = false
        self.allowDetailGroupTypes = [.timer]
        focus.addUpdater(self, for: [.session])
    }
    
    func setupInfoView(timer: FocusTimer) {
        let infoView = FocusStatsSpecificTimerInfoView(timer: timer)
        self.infoView = infoView
    }
    
    func setupInfoView(task: TaskRepresentable) {
        let infoView = FocusStatsSpecificTaskInfoView(task: task)
        self.infoView = infoView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.contentInset = UIEdgeInsets(bottom: infoViewHeight + infoViewEdgeMargins.verticalLength)
        self.layoutInfoView(infoView)
    }
    
    override func handleFirstAppearance() {
        self.view.addSubview(self.infoView)
        self.layoutInfoView(infoView, isHidden: true) /// 隐藏infoView
        UIView.animate(withDuration: 0.6,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
            self.layoutInfoView(self.infoView)
        }, completion: nil)
    }
    
    /// 布局任务信息视图
    private func layoutInfoView(_ infoView: UIView, isHidden: Bool = false){
        let layoutFrame = view.safeLayoutFrame().inset(by: infoViewEdgeMargins)
        let cornerRadius = 16.0
        infoView.width = min(640.0, layoutFrame.width)
        infoView.height = infoViewHeight
        if isHidden {
            infoView.top = view.height
        } else {
            infoView.bottom = layoutFrame.maxY
        }
        
        infoView.centerX = layoutFrame.midX
        infoView.layer.cornerRadius = cornerRadius
        infoView.layer.setLayerShadow(color: Color(0x000000, 0.1),
                                      offset: CGSize(width: 0.0, height: -2.0),
                                      radius: cornerRadius)
        infoView.layoutIfNeeded()
    }
    
    // MARK: - FocusSessionProcessorDelegate
    func didAddFocusSessions(_ sessions: [FocusSession]) {
        self.infoView.reloadData()
    }
    
    func didUpdateFocusSession(_ session: FocusSession) {
        self.infoView.reloadData()
    }
    
    func didDeleteFocusSession(_ session: FocusSession) {
        self.infoView.reloadData()
    }
}
