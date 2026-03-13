//
//  HabitTaskStatusProgressView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/24.
//

import Foundation
import UIKit

/// 习惯任务状态进度视图
class HabitTaskStatusProgressView: UIView {
    
    // MARK: - Properties
    
    var progressColor: UIColor? {
        didSet {
            progressView.progressLineColor = progressColor
        }
    }
    
    var statusImageColor: UIColor? = .white {
        didSet {
            statusImageView.updateImage(withColor: statusImageColor)
        }
    }
    
    var progress: CGFloat = 0.0 {
        didSet {
            progressView.progress = progress
        }
    }
    
    private(set) var status: HabitTaskStatus = .notStarted
    
    /// emoji 标签
    var emojiLabel: UILabel!
    
    /// 其它信息标签（仅在 status 为未开始状态时显示）
    var infoLabel: UILabel!
    
    /// 状态图片
    var statusImageView: UIImageView!
    
    /// 进度视图
    var progressView: TPCircleOutlineProgressView!
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    // MARK: - Setup Methods
    
    private func setupSubviews() {
        setupProgressView()
        setupEmojiLabel()
        setupInfoLabel()
        setupStatusImageView()
        updateStatus()
    }
    
    /// 设置进度视图
    private func setupProgressView() {
        progressView = TPCircleOutlineProgressView()
        progressView.progressLineWidth = 4.0
        progressView.progress = 0.0
        addSubview(progressView)
    }
    
    /// 设置 Emoji 标签
    private func setupEmojiLabel() {
        emojiLabel = UILabel()
        emojiLabel.font = UIFont.boldSystemFont(ofSize: 28.0)
        emojiLabel.textAlignment = .center
        addSubview(emojiLabel)
    }
    
    /// 设置信息标签
    private func setupInfoLabel() {
        infoLabel = UILabel()
        infoLabel.textAlignment = .center
        infoLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        infoLabel.adjustsFontSizeToFitWidth = true
        infoLabel.textColor = Color(0xE1E1E1)
        addSubview(infoLabel)
    }
    
    /// 设置状态图片视图
    private func setupStatusImageView() {
        statusImageView = UIImageView()
        addSubview(statusImageView)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.frame = bounds
        statusImageView.frame = bounds
        statusImageView.updateContentMode()
        
        infoLabel.frame = bounds.middleCircleInnerSquareRect
        emojiLabel.frame = bounds
    }
    
    // MARK: - Status Updates
    
    func setStatus(_ status: HabitTaskStatus, animated: Bool = false) {
        guard self.status != status else {
            return
        }
        
        self.status = status
        if animated {
            UIView.animate(withDuration: 0.4) {
                self.updateStatus()
            }
        } else {
            self.updateStatus()
        }
    }
    
    /// 更新状态显示
    private func updateStatus() {
        updateEmojiLabelVisibility()
        updateStatusImageViewVisibility()
        updateProgressViewVisibility()
        updateInfoLabelVisibility()
        updateStatusImage()
        updateEmojiLabel()
    }
    
    /// 更新 Emoji 标签可见性
    private var shouldShowEmoji: Bool {
        return status == .skipped(nil) || status == .failed(nil)
    }
    
    private func updateEmojiLabelVisibility() {
        emojiLabel.alpha = shouldShowEmoji ? 1.0 : 0.0
    }
    
    /// 更新状态图片视图可见性
    var showStatusImage: Bool {
        return status == .completed
    }
    
    private func updateStatusImageViewVisibility() {
        statusImageView.alpha = showStatusImage ? 1.0 : 0.0
    }
    
    /// 更新进度视图可见性
    private func updateProgressViewVisibility() {
        let shouldHideProgress = (status == .notStarted || 
                                  status == .failed(nil) || 
                                  status == .skipped(nil))
        progressView.alpha = shouldHideProgress ? 0.0 : 1.0
    }
    
    /// 更新信息标签可见性
    private func updateInfoLabelVisibility() {
        let shouldShowInfoLabel =  !showStatusImage && !shouldShowEmoji
        infoLabel.alpha = shouldShowInfoLabel ? 1.0 : 0.0
    }
    
    /// 更新状态图片
    private func updateStatusImage() {
        var image: UIImage? = nil
        if status == .completed {
            image = resGetImage("habit_week_day_checkmark_40")
        }
        
        statusImageView.image = image
        statusImageView.updateImage(withColor: statusImageColor)
    }
    
    /// 更新 Emoji 标签内容
    private func updateEmojiLabel() {
        var emoji: Character?
        switch status {
        case .failed(let reason), .skipped(let reason):
            emoji = reason?.first
        default:
            break
        }
        
        emojiLabel.text = emoji.map { String($0) }
    }
}
