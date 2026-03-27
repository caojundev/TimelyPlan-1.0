//
//  FocusStatsInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/2.
//

import Foundation
import UIKit

class FocusStatsInfoView: UIView {
    
    let durationInfoWidth = 120.0
    
    /// 专注总时长信息视图
    lazy var durationInfoView: TPInfoView = {
        let textColor = resGetColor(.title)
        let view = TPInfoView()
        view.padding = UIEdgeInsets(horizontal: 2.0)
        view.titleConfig.adjustsFontSizeToFitWidth = true
        view.titleConfig.font = UIFont.boldSystemFont(ofSize: 16.0)
        view.titleConfig.textAlignment = .center
        view.titleConfig.textColor = textColor
        
        view.subtitleConfig.adjustsFontSizeToFitWidth = true
        view.subtitleConfig.textColor = textColor
        view.subtitleConfig.textAlignment = .center
        view.subtitleConfig.alpha = 0.5
        view.subtitleTopMargin = 10.0
        view.addSeparator(position: .left)
        view.separatorEdgeInset = UIEdgeInsets(vertical: 10.0)
        
        view.title = "---"
        view.subtitle = resGetString("Total Duration")
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
        self.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = self.layoutFrame()
        durationInfoView.width = durationInfoWidth
        durationInfoView.height = layoutFrame.height
        durationInfoView.right = layoutFrame.maxX
        durationInfoView.top = layoutFrame.minY
    }
    
    func setupSubviews() {
        self.backgroundColor = .secondarySystemGroupedBackground
        addSubview(durationInfoView)
    }
    
    func reloadData() {
        
    }
}

class FocusStatsSpecificTimerInfoView: FocusStatsInfoView {
    
    private let indicatorMargin = 10.0
    
    private let indicatorSize = CGSize(width: 6.0, height: 36.0)
    
    private lazy var indicatorView: UIView = {
        let view = UIView()
        view.size = indicatorSize
        view.layer.cornerRadius = indicatorSize.width / 2.0
        view.backgroundColor = .clear
        return view
    }()
    
    /// 计时器信息视图
    private lazy var timerInfoView: TPInfoView = {
        let view = TPInfoView()
        view.titleConfig.font = UIFont.boldSystemFont(ofSize: 16.0)
        view.titleConfig.numberOfLines = 1
        return view
    }()
    
    let timer: FocusTimer
    
    init(timer: FocusTimer) {
        self.timer = timer
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        self.padding = UIEdgeInsets(top: 10.0, left: 30.0, bottom: 10.0, right: 10.0)
        addSubview(indicatorView)
        addSubview(timerInfoView)
        indicatorView.backgroundColor = timer.color
        timerInfoView.title = timer.name
        timerInfoView.subtitle = timer.timerDescription
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = self.layoutFrame()
        indicatorView.right = layoutFrame.minX - indicatorMargin
        indicatorView.alignVerticalCenter()

        timerInfoView.width = layoutFrame.width - durationInfoView.width
        timerInfoView.height = layoutFrame.height
        timerInfoView.left = layoutFrame.minX
        timerInfoView.top = layoutFrame.minY
    }
    
    override func reloadData() {
        focus.fetchDuration(forTask: nil, timer: self.timer) {[weak self] result in
            self?.durationInfoView.title = Duration(result).attributedTitle()
        }
    }
}

class FocusStatsSpecificTaskInfoView: FocusStatsInfoView {
    
    /// 任务信息视图
    private lazy var taskInfoView: TPInfoView = {
        let view = TPInfoView()
        view.titleConfig.font = UIFont.boldSystemFont(ofSize: 16.0)
        view.titleConfig.numberOfLines = 1
        return view
    }()
    
    let task: TaskRepresentable
    
    init(task: TaskRepresentable) {
        self.task = task
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        self.padding = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 10.0)
        self.addSubview(taskInfoView)
        let feature = self.task.feature
        taskInfoView.title = feature.snapshotName ?? resGetString("Untitled Task")
        taskInfoView.subtitle = feature.type.title
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = self.layoutFrame()
        taskInfoView.width = layoutFrame.width - durationInfoView.width
        taskInfoView.height = layoutFrame.height
        taskInfoView.left = layoutFrame.minX
        taskInfoView.top = layoutFrame.minY
    }
    
    override func reloadData() {
        focus.fetchDuration(forTask: self.task, timer: nil) {[weak self] result in
            self?.durationInfoView.title = Duration(result).attributedTitle()
        }
    }
}
