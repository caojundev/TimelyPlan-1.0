//
//  HabitRecordResultInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/13.
//

import Foundation

class HabitRecordResultInfoView: UIView, TPCustomPopupContent {
    
    var didClickLog: (() -> Void)?
    
    let task: HabitTask
    
    let record: HabitRecord
    
    let date: Date
    
    private var infoView = TPImageInfoView()
    
    private lazy var logButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.image = resGetImage("habit_menu_log_24")
        button.imageConfig.color = .white
        button.normalBackgroundColor = Color(0x456FEF)
        button.cornerRadius = .greatestFiniteMagnitude
        button.addTarget(self, action: #selector(clickLog(_:)), for: .touchUpInside)
        return button
    }()

    init(task: HabitTask, record: HabitRecord, date: Date) {
        self.task = task
        self.record = record
        self.date = date
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        self.backgroundColor = .secondarySystemBackground
        self.padding = UIEdgeInsets(left: 16.0, right: 16.0)
        infoView.imageConfig.size = .size(8)
        infoView.imageConfig.shouldRenderImageWithColor = false
        infoView.titleConfig.font = .boldSystemFont(ofSize: 16.0)
        infoView.subtitleConfig.font = .systemFont(ofSize: 13.0)
        addSubview(infoView)
        addSubview(logButton)
        updateInfoView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        logButton.size = .init(width: 48.0, height: 32.0)
        logButton.right = layoutFrame.maxX
        logButton.centerY = layoutFrame.midY
    
        infoView.width = logButton.left - layoutFrame.minX
        infoView.height = layoutFrame.height
        infoView.origin = layoutFrame.origin
    }
    
    private func updateInfoView() {
        /// 更新信息视图
        infoView.title = task.name
        
        var imageName: String?
        var subtitle: String?
        let status = task.status(with: record)
        switch status {
        case .notStarted, .inProgress:
            imageName = nil
            subtitle = nil
        case .completed:
            imageName = "habit_status_completed_36"
            subtitle = resGetString("Completed")
        case .skipped(_):
            imageName = "habit_status_skipped_36"
            subtitle = resGetString("Skipped")
        case .failed(_):
            imageName = "habit_status_failed_36"
            subtitle = resGetString("Failed")
        }
        
        infoView.imageContent = .withName(imageName)
        infoView.subtitle = subtitle
    }
    
    @objc func clickLog(_ button: UIButton) {
        TPImpactFeedback.impactWithSoftStyle()
        didClickLog?()
    }
}
