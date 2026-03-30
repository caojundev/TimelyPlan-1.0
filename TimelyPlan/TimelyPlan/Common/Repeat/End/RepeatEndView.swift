//
//  RepeatEndView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/6.
//

import Foundation
import UIKit

class RepeatEndView: UIView {
    
    /// 默认高度
    static let defaultHeight = 60.0
    
    var repeatEnd: RepeatEnd? {
        didSet {
            endButton.repeatEnd = repeatEnd
        }
    }
    
    var repeatEndDidChange: ((RepeatEnd?) -> Void)?
    
    private let endButton = RepeatEndButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        endButton.addTarget(self,
                            action: #selector(clickEnd(_:)),
                            for: .touchUpInside)
        self.addSubview(endButton)
        self.addSeparator(position: .top)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .systemBackground
        endButton.frame = bounds
    }
    
    @objc private func clickEnd(_ button: RepeatEndButton) {
        /// 编辑重复结束
        RepeatEndEditViewController.editRepeatEnd(self.repeatEnd) { repeatEnd in
            self.repeatEnd = repeatEnd
            self.repeatEndDidChange?(repeatEnd)
        }
    }
}

private class RepeatEndButton: TPBaseButton {
    
    var repeatEnd: RepeatEnd? {
        didSet {
           updateRepeatEndInfo()
        }
    }
    
    /// 信息视图
    private lazy var infoView: TPImageInfoView = {
        let view = TPImageInfoView()
        view.subtitleTopMargin = 5.0
        view.titleConfig.numberOfLines = 1
        view.subtitleConfig.numberOfLines = 1
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        preferredTappedScale = 1.0
        contentView.padding = UIEdgeInsets(horizontal: 15.0, vertical: 5.0)
        contentView.addSubview(infoView)
        normalBackgroundColor = .systemBackground
        selectedBackgroundColor = Color(0x888888, 0.1)
        infoView.title = resGetString("Repeat End")
        infoView.imageName = "schedule_repeatEnd_24"
        updateRepeatEndInfo()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = contentView.layoutFrame()
    }
    
    private func updateRepeatEndInfo() {
        var subtitle: String?
        if let repeatEnd = repeatEnd {
            subtitle = repeatEnd.endText
        } else {
            subtitle = RepeatEnd.neverEndText
        }
        
        infoView.subtitle = subtitle
    }
    
}

