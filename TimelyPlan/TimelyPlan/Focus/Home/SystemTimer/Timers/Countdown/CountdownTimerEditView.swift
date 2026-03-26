//
//  CountdownTimerEditView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/15.
//

import Foundation
import UIKit

class CountdownTimerEditView: UIView {
    
    /// 结束编辑回调
    var didEndEditing: ((TimeInterval) -> ())?
    
    /// 进度视图
    let progressView: CountdownTimerProgressView = CountdownTimerProgressView()
    
    /// 分钟选择器
    let pickerView = TPCountPickerView(style: .backgroundColorCleared)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(progressView)
        
        pickerView.minimumCount = 5
        pickerView.maximumCount = 180
        pickerView.stepCount = 5
        pickerView.componentHeight = 65.0
        pickerView.font = UIFont.boldSystemFont(ofSize: 32.0)
        pickerView.tailingLabel.textAlignment = .left
        pickerView.tailingTextForCount = { count in
            return resGetString("Minutes")
        }
        
        pickerView.didPickCount = { [weak self] count in
            let duration = TimeInterval(count * SECONDS_PER_MINUTE)
            self?.progressView.setDuration(duration, animated: true)
            self?.didEndEditing?(duration)
        }
        
        progressView.addSubview(pickerView)
        pickerView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.padding = UIEdgeInsets(value: 5.0)
        let layoutFrame = self.layoutFrame()
        let progressWidth = layoutFrame.shortSideLength
        progressView.size = CGSize(width: progressWidth, height: progressWidth)
        progressView.alignCenter()
        
        pickerView.frame = progressView.bounds
        pickerView.layer.cornerRadius = pickerView.halfWidth
    }
    
    // MARK: - Public Methods
    public func setDuration(_ duration: TimeInterval, animated: Bool) {
        let minutes = Int(duration) / SECONDS_PER_MINUTE
        pickerView.selectCount(minutes, animated: animated)
        progressView.setDuration(duration, animated: animated)
    }
    
    /**
     设置动画持续时间，从零开始过渡到指定时长
     - Parameter duration: 要设置的持续时间（以秒为单位）
     */
    public func setDurationWithAnimationFromZero(_ duration: TimeInterval) {
        // 重置选择器和进度条到初始状态
        self.pickerView.selectCount(0, animated: false)
        self.progressView.setDuration(0, animated: false)
        
        // 延迟0.1秒后执行动画，确保UI有足够时间重置
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let minutes = Int(duration) / SECONDS_PER_MINUTE
            self.pickerView.selectCount(minutes, animated: true)
            self.progressView.setDuration(duration, animated: true)
        }
    }
}
