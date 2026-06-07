//
//  TodoTaskQuickSendView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/23.
//

import Foundation
import UIKit
 
class TodoTaskQuickAddSendView: UIView {
    
    /// 任务所属板块
    var section: TodoSectionFeature = .defaultSection {
        didSet {
            sectionButton.section = section
        }
    }

    /// 选中板块回调
    var didSelectSection: ((TodoSectionFeature) -> Void)? {
        didSet {
            sectionButton.didSelectSection = didSelectSection
        }
    }
    
    /// 发送按钮是否可用
    var isSendEnabled: Bool = false {
        didSet {
            sendButton.isEnabled = isSendEnabled
        }
    }
    
    /// 点击发送按钮
    var didClickSend: ((UIButton) -> Void)?

    /// 列表选择按钮
    private lazy var sectionButton: TodoTaskQuickAddSectionPicker = {
        let button = TodoTaskQuickAddSectionPicker()
        return button
    }()
    
    /// 发送按钮
    private let sendButtonSize: CGSize = .size(8)
    private lazy var sendButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.isEnabled = isSendEnabled
        button.padding = .zero
        button.size = sendButtonSize
        button.cornerRadius = .greatestFiniteMagnitude
        button.normalBackgroundColor = .primary
        button.imageConfig.color = Color(0xFFFFFF, 0.9)
        button.image = resGetImage("arrow_up_24")
        button.addTarget(self,
                         action: #selector(clickSend(_:)),
                         for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 10.0)
        self.addSeparator(position: .top)
        self.addSubview(self.sectionButton)
        self.addSubview(self.sendButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = self.layoutFrame()
        sectionButton.sizeToFit()
        sectionButton.width = min(layoutFrame.width / 2.0, sectionButton.width)
        sectionButton.left = layoutFrame.minX
        sectionButton.centerY = layoutFrame.midY
    
        sendButton.right = layoutFrame.maxX
        sendButton.alignVerticalCenter()
    }
    
    // MARK: - Event Response
    /// 点击完成
    @objc func clickSend(_ button: UIButton) {
        self.didClickSend?(button)
    }
}
