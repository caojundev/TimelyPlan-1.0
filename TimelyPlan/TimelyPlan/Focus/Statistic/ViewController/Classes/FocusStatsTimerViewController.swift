//
//  FocusStatsTimerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/4.
//

import Foundation

class FocusStatsTimerViewController: FocusStatsBaseViewController {
    
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
        self.infoView.statsInfo = FocusStatsInfo(color: timer.color,
                                                 title: timer.name,
                                                 subtitle: timer.timerInfo)
        self.canSelectDetailGroupType = false
        self.allowDetailGroupTypes = [.task]
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
    func layoutInfoView(_ infoView: UIView, isHidden: Bool = false){
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
}
