//
//  FocusRunningTimerFeatureView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/9.
//

import Foundation

class FocusRunningTimerNameView: UIView {

    /// 当前计时器
    var name: String? {
        didSet {
            updateName(animated: true)
        }
    }
    
    /// 计时器按钮
    private lazy var infoLabel: TPLabel = {
        let label = TPLabel()
        label.textColor = resGetColor(.title)
        label.textAlignment = .center
        label.font = BOLD_SMALL_SYSTEM_FONT
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(infoLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = bounds.inset(by: UIEdgeInsets(horizontal: 10.0))
        infoLabel.sizeToFit()
        if infoLabel.width > layoutFrame.width {
            infoLabel.width = layoutFrame.width
        }
        
        infoLabel.center = layoutFrame.center
    }
    
    /// 更新任务名称
    private func updateName(animated: Bool) {
        infoLabel.text = name
        if animated {
            animateLayout(withDuration: 0.25)
        } else {
            setNeedsLayout()
        }
    }
}
