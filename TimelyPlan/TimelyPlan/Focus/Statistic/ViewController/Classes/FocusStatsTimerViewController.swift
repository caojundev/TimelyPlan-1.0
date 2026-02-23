//
//  FocusStatsTimerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/4.
//

import Foundation

class FocusStatsTimerViewController: FocusStatsBaseViewController,
                                        FocusSessionProcessorDelegate {
    
    /// 信息视图间距
    let infoViewMargin: CGFloat = 10.0
    
    /// 专注任务信息视图
    lazy var infoView: FocusStatsInfoView = {
        let view = FocusStatsInfoView()
        return view
    }()

    init(timer: FocusTimer, type: StatsType = .week, allowTypes: [StatsType] = StatsType.allCases, date: Date = .now) {
        super.init(type: type, allowTypes: allowTypes, date: date)
        self.timer = timer
        self.canSelectDetailGroupType = false
        self.allowDetailGroupTypes = [.task]
        self.reloadData()
        focus.addUpdaterDelegate(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.layoutInfoView(infoView)
        self.contentInset = UIEdgeInsets(bottom: infoView.height + 2 * infoViewMargin)
    }
    
    override func handleFirstAppearance() {
        self.view.addSubview(self.infoView)
        self.layoutInfoView(infoView, isHidden: true) /// 隐藏infoView
        self.view.animateLayout(withDuration: 0.6, usingSpring: true)
    }
    
    /// 布局任务信息视图
    private func layoutInfoView(_ infoView: UIView, isHidden: Bool = false){
        let layoutFrame = view.safeLayoutFrame().inset(by: UIEdgeInsets(value: infoViewMargin))
        let cornerRadius = 16.0
        infoView.width = min(640.0, layoutFrame.width)
        infoView.height = 80.0
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
    
    /// 重新加载数据
    private func reloadData() {
        guard let timer = self.timer else {
            return
        }
        
        let duration = focus.getTotalDuration(for: timer)
        self.infoView.statsInfo = FocusStatsInfo(color: timer.color,
                                                 title: timer.name,
                                                 subtitle: timer.timerDescription,
                                                 totalDuration: Duration(duration))
        
    }
    
    // MARK: - FocusSessionProcessorDelegate
    func didAddFocusSessions(_ sessions: [FocusSession]) {
        self.reloadData()
    }
    
    func didUpdateFocusSession(_ session: FocusSession) {
        self.reloadData()
    }
    
    func didDeleteFocusSession(with record: FocusRecord) {
        self.reloadData()
    }
}
